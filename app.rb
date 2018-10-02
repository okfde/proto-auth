# Thanks to
# https://gist.github.com/tritonrc/783358
# for basic approach

require 'net-ldap'
require 'sanitize'
require 'sinatra'
require 'sinatra/base'

class Forbidden < StandardError
  def http_status; 403 end
end

class App < Sinatra::Base
  LDAP_HOST = ENV['LDAP_HOST']
  LDAP_PORT = ENV['LDAP_PORT']
  ADMIN_DN = ENV['ADMIN_DN']
  ADMIN_PW = ENV['ADMIN_PW']
  PEOPLE_DN = ENV['PEOPLE_DN']
  PEOPLE_FILTER = Net::LDAP::Filter.eq('objectClass', 'inetOrgPerson')

  enable :sessions

  helpers do
    def authorize!
      redirect to('/login') unless session[:user_dn]
    end

    def authenticate_with_ldap(username, password)
      username = Sanitize.fragment(username)
      password = Sanitize.fragment(password)

      dn = make_dn(username)
      auth = make_auth(dn, password)
      ldap = make_ldap(auth)

      if ldap.bind
        {dn: dn, pw: password, uid: username}
      else
        false
      end
    end

    def make_ldap(auth)
      Net::LDAP.new(host: LDAP_HOST,
                    port: LDAP_PORT,
                    auth: auth)
    end

    def make_dn(username)
      if username == 'admin'
        ADMIN_DN
      else
        user_dn(username)
      end
    end

    def make_auth(dn, pw)
      { method: :simple,
	username: dn,
	password: pw }
    end

    def admin?
      session[:uid] == 'admin'
    end

    def owner?(uid)
      admin? || session[:uid] == uid
    end

    def user_dn(uid)
      "uid=#{uid}," + PEOPLE_DN
    end

    def can_register?
      ENV['REGISTRATION_OPEN'] == 'true'
    end
  end

  get '/' do
    authorize!
    redirect to('/profile')
  end

  get '/login' do
    redirect to '/profile' if session[:uid]
    @ropen = can_register?
    slim :login
  end

  post '/login' do
    user = authenticate_with_ldap(params[:username], params[:password])

    if user && user[:dn]
      session[:user_dn] = user[:dn]
      session[:uid] = user[:uid]
      redirect to("/profile/#{params[:username]}?status=Success&message=You are logged in")
    else
      redirect to('/login?status=Error&message=Wrong username or password')
    end
  end

  get '/profile' do
    authorize!
    redirect to("/profile/#{session[:uid]}")
  end

  get '/profile/:username' do
    authorize!
    raise Forbidden, 'Unauthorized' unless owner?(params[:username])
    slim :index
  end

  get '/logout' do
    session.clear
    redirect to '/login'
  end

  get '/profile/:username/password' do
    authorize!
    raise Forbidden, 'Unauthorized' unless owner?(params[:username])
    slim :password
  end

  post '/profile/:username/password' do
    authorize!
    raise Forbidden, 'Unauthorized' unless owner?(params[:username])

    current_password = Sanitize.fragment(params[:current_password])
    new_password = Sanitize.fragment(params[:new_password])
    new_password_confirmation = Sanitize.fragment(params[:new_password_confirmation])

    password_not_ok = new_password.empty? || (new_password != new_password_confirmation)
    if password_not_ok
      status = "status=Error&message=Password and confirmation do not match"
      redirect to "/profile/#{session[:uid]}/password?#{status}"
    end

    dn = session[:user_dn]
    auth = make_auth(dn, current_password)
    ldap = make_ldap(auth)
    ldap.password_modify(dn: dn,
                         auth: auth,
                         old_password: current_password,
                         new_password: new_password)

    status = "status=#{ldap.get_operation_result.message}&message=Password updated"
    redirect to "/profile/#{session[:uid]}?#{status}"
  end

  get '/new' do
    @ropen = can_register?
    slim :new
  end

  post '/create' do
    raise Forbidden unless can_register?

    cn = Sanitize.fragment(params[:full_name])
    username = Sanitize.fragment(params[:username])
    password = Sanitize.fragment(params[:password])
    password_confirmation = Sanitize.fragment(params[:password_confirmation])
    email = Sanitize.fragment(params[:email])

    password_not_ok = password.empty? || (password != password_confirmation)

    redirect to "/new?status=Error&message=Password is either empty or does not match" if password_not_ok

    auth = make_auth(ADMIN_DN, ADMIN_PW)

    udn = user_dn(username)
    attr = {
      objectclass: ["top", "inetOrgPerson"],
      uid: username,
      cn: cn,
      sn: cn.split(' ').last,
      mail: email,
      userpassword: password,
      ou: ENV['REGISTRATION_OU']

    Net::LDAP.open(host: LDAP_HOST,
                   port: LDAP_PORT,
                   auth: auth) do |ldap|
      ldap.add(:dn => udn, :attributes => attr)

      if ldap.get_operation_result.message == 'Success'
        session[:user_dn] = udn
        session[:uid] = username
        status = "status=Success&message=Account created"
        redirect to("/profile/#{params[:username]}?#{status}")
      else
        redirect to("/new?status=Error&message=#{ldap.get_operation_result.message}")
      end
    end
  end

  error 403 do
    'Error 403 Forbidden, have you logged in properly?'
  end
end

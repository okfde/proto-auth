# Thanks to
# https://gist.github.com/tritonrc/783358
# for basic approach

require 'net-ldap'
require 'sanitize'
require 'sinatra'
require 'sinatra/base'

require './helpers/application_helper'

class Forbidden < StandardError
  def http_status; 403 end
end

class App < Sinatra::Base

  helpers ApplicationHelper

  LDAP_HOST = ENV['LDAP_HOST']
  LDAP_PORT = ENV['LDAP_PORT']
  ADMIN_DN = ENV['ADMIN_DN']
  ADMIN_PW = ENV['ADMIN_PW']
  PEOPLE_DN = ENV['PEOPLE_DN']
  PEOPLE_FILTER = Net::LDAP::Filter.eq('objectClass', 'inetOrgPerson')

  enable :sessions

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

    current_password = params[:current_password].strip
    new_password = params[:new_password].strip
    new_password_confirmation = params[:new_password_confirmation].strip

    password_not_ok = new_password.empty? || (new_password != new_password_confirmation)
    if password_not_ok
      status = "status=Error&message=Password and confirmation do not match"
      redirect to "/profile/#{session[:uid]}/password?#{status}"
    end

    dn = session[:user_dn]
    auth = make_auth(dn, current_password)
    ldap = make_ldap(auth)
    unless ldap.bind
      status = "status=Error&message=Password is wrong"
      redirect to "/profile/#{session[:uid]}/password?#{status}"
    end
    ldap.password_modify(dn: dn,
                         auth: auth,
                         old_password: current_password,
                         new_password: new_password)

    status = "status=#{ldap.get_operation_result.message}&message=Password updated"
    redirect to "/profile/#{session[:uid]}?#{status}"
  end

  get '/forgot_password' do
    slim :forgot_password
  end

  post '/forgot_password' do
    email = Sanitize.fragment(params[:useremail])
    status = "status=Success&message=Wenn dieser Username existiert, bekommst du eine Email"
    users = search_user_by_email(email)
    redirect to "/forgot_password?#{status}" unless users.length >= 1

    # now we know we have at least one user
    # time to send them emails

    users.each do |entry|
      entry.each do |attribute, values|
        if attribute.to_s == 'mail'
          values.each { |mail| puts "Sending mail to #{mail}" }
        end
      end
    end

    redirect to "/forgot_password?#{status}"
  end

  get '/new' do
    @ropen = can_register?
    slim :new
  end

  post '/create' do
    raise Forbidden unless can_register?

    cn = Sanitize.fragment(params[:full_name])
    username = Sanitize.fragment(params[:username])
    password = params[:password].strip
    password_confirmation = params[:password_confirmation].strip
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
    }

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

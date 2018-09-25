# https://gist.github.com/tritonrc/783358

# https://fairwaytech.com/2013/10/a-beginners-guide-to-querying-ldap-with-ruby-also-spaceballs/
# https://gist.github.com/jeffjohnson9046/7012167

require 'net-ldap'
require 'sanitize'
require 'sinatra'
require 'sinatra/base'

#PEOPLE_FILTER = Net::LDAP::Filter.eq('objectClass', 'inetOrgPerson')
class App < Sinatra::Base

  LDAP_HOST = 'localhost'
  LDAP_PORT = 389

  ADMIN_DN = 'cn=admin,dc=nodomain,dc=xyz'
  PEOPLE_DN = 'ou=people,dc=nodomain,dc=xyz'

  enable :sessions

  helpers do
    def authorize!
      redirect(to('/login')) unless session[:user_id]
    end

    def authenticate_with_ldap(username, password)
      username = Sanitize.fragment(username)
      password = Sanitize.fragment(password)

      if username == 'admin'
        dn = ADMIN_DN
      else
        dn = user_dn(username)
      end

      auth = {
	:method => :simple,
	:username => dn,
	:password => password
      }
      ldap = Net::LDAP.new(:host => LDAP_HOST,
                           :port => LDAP_PORT,
                           :auth => auth)

      if ldap.bind
        # authentication succeeded
        ldap.get_operation_result.message
      else
        # authentication failed
        false
      end
    end

    def session_uid
      request.env['REMOTE_USER']
    end

    def admin?
      session_uid == 'admin'
    end

    def owner?(uid)
      admin? || session_uid == uid
    end

    def user_dn(uid)
      "uid=#{uid}," + PEOPLE_DN
    end
  end

  get '/' do
    authorize!
    redirect to('/profile')
  end

  get '/login' do
    username = params[:username]
    password = params[:password]
    slim :login
  end

  post '/login' do
    # cn=admin,dc=nodomain,dc=xyz
    user = authenticate_with_ldap(params[:username], params[:password])

    puts "#########"
    puts user

    if user == 'Success'
      session[:user_id] = 2345
      # Or: session[:logged_in] = true, depending on your needs.
      redirect to('/profile')
    else
      redirect to('/login?status=wrong')
    end
  end

  get '/profile' do
    authorize!

    ldap = Net::LDAP.new(:host => LDAP_HOST)
    persons = ldap.search(:base => 'dc=nodomain,dc=xyz')
    raise Sinatra::NotFound unless persons
    @person = persons.first

    slim :index
  end
end

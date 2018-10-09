module ApplicationHelper
  def authorize!
    redirect to('/login') unless session[:user_dn]
  end

  def authenticate_with_ldap(username, password)
    username = Sanitize.fragment(username)
    password = password.strip

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
    Net::LDAP.new(host: ENV['LDAP_HOST'],
                  port: ENV['LDAP_PORT'],
                  auth: auth)
  end

  def make_dn(username)
    if username == 'admin'
      ENV['ADMIN_DN']
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
    "uid=#{uid}," + ENV['PEOPLE_DN']
  end

  def can_register?
    ENV['REGISTRATION_OPEN'] == 'true'
  end
end

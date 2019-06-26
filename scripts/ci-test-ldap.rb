# coding: utf-8
require 'net/ldap'

auth = { method: :simple,
         username: 'uid=john,ou=People,dc=example,dc=com',
         password: 'johnldap' }

ldap = Net::LDAP.new(host: ENV['LDAP_HOST'],
              port: ENV['LDAP_PORT'],
              auth: auth)

if ldap.bind
  puts "\nCould bind to LDAP\n🎉🎉🎉\n"
  exit 0
else
  puts "\nFailed binding to LDAP\n😩\n"
  exit 1
end

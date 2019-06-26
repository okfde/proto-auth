# coding: utf-8
require 'net/ldap'

ldap = Net::LDAP.new
ldap.host = ENV['LDAP_HOST']
ldap.port = ENV['LDAP_PORT']
ldap.auth ENV['ADMIN_DN'], ENV['ADMIN_PW']
if ldap.bind
  echo "\nCould bind to LDAP\n🎉🎉🎉\n"
  exit 0
else
  echo "\nFailed binding to LDAP\n😩\n"
  exit 1
end

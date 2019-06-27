# coding: utf-8
require "spec_helper"

class TestHelper
  include ApplicationHelper
end

describe 'ApplicationHelpers' do
  let(:helpers) { TestHelper.new }

  describe '#authenticate_with_ldap' do
    it "authenticates when credentials are correct" do
      username = "john"
      password = "johnldap"
      expect(helpers.authenticate_with_ldap(username, password))
        .to eq({dn: "uid=john,ou=People,dc=example,dc=com",
                pw: "johnldap",
                uid: "john"})
    end
  end

  describe '#make_ldap' do
    it "returns valid LDAP object" do
      auth = { method: :simple,
               username: 'dn=admin,dc=nodomain,dc=de',
               password: 'passwort' }
      expect(helpers.make_ldap(auth).is_a?(Net::LDAP)).to be true
    end
  end

  describe '#make_dn' do
    it 'returns admin dn if username is admin' do
      env_old = ENV['ADMIN_DN']
      ENV['ADMIN_DN'] = 'dn=admin,dc=nodomain,dc=de'
      expect(helpers.make_dn('admin')).to eq(ENV['ADMIN_DN'])
      ENV['ADMIN_DN'] = env_old
    end
    it 'returns user dn if username is not admin' do
      env_old = ENV['PEOPLE_DN']
      ENV['PEOPLE_DN'] = 'ou=people,dc=nodomain,dc=de'
      expect(helpers.make_dn('foo')).to eq('uid=foo,ou=people,dc=nodomain,dc=de')
      ENV['PEOPLE_DN'] = env_old
    end
  end

  describe '#make_auth' do
    it 'returns hash of auth config' do
      out = { method: :simple,
              username: 'dn=admin,dc=nodomain,dc=de',
              password: 'passwort' }
      expect(helpers.make_auth('dn=admin,dc=nodomain,dc=de', 'passwort')).to eq(out)
    end
  end

  describe '#admin?' do
    pending 'returns true if session uid is admin' do
      expect(helpers.admin?).to be true
    end
    pending 'returns false if session uid is other' do
      expect(helpers.admin?).to be false
    end
  end

  describe '#user_dn' do
    it 'returns concatenated user dn string' do
      env_old = ENV['PEOPLE_DN']
      ENV['PEOPLE_DN'] = 'ou=people,dc=nodomain,dc=de'
      expect(helpers.user_dn('foo')).to eq('uid=foo,ou=people,dc=nodomain,dc=de')
      ENV['PEOPLE_DN'] = env_old
    end
  end

  describe '#can_register?' do
    it 'returns true if registration is open' do
      env_old = ENV['REGISTRATION_OPEN']
      ENV['REGISTRATION_OPEN'] = 'true'
      expect(helpers.can_register?).to be true
      ENV['REGISTRATION_OPEN'] = env_old
    end
    it 'returns false if registration is closed' do
      env_old = ENV['REGISTRATION_OPEN']
      ENV['REGISTRATION_OPEN'] = 'false'
      expect(helpers.can_register?).to be false
      ENV['REGISTRATION_OPEN'] = env_old
    end
  end
end

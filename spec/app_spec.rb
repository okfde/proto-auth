# coding: utf-8
require "spec_helper"

describe App do
  let(:app) { App.new }

  ldap_base = 'dc=example,dc=com'
  ldap_user_dn = "uid=john,ou=People,#{ldap_base}"
  ldap_user_pw = 'johnldap'

  session_data = { user_dn: ldap_user_dn,
                   uid: 'john' }
  new_account_data = { full_name: 'John Doe',
                       user_name: 'john',
                       password: ldap_user_pw,
                       password_confirmation: ldap_user_pw,
                       email: 'johnl@example.com' }

  shared_examples_for 'raises 403' do
    it 'raises 403 Error' do
      expect(response.status).to eq 403
      expect(response.body).to match 'Error 403'
    end
  end

  shared_examples_for 'redirects to /login' do
    it 'redirects to /login' do
      expect(response).to redirect_to '/login'
    end
  end

  context 'GET /' do
    context 'given user is logged in' do
      let(:response) { get '/', {}, 'rack.session' => session_data }
      it 'redirects to /profile' do
        expect(response).to redirect_to '/profile'
      end
    end

    context 'given user is not logged in' do
      let(:response) { get "/" }
      include_examples 'redirects to /login'
    end
  end

  context 'GET /login' do
    context 'given user is logged in' do
      let(:response) { get '/login', {}, 'rack.session' => session_data }
      it 'redirects to /profile' do
        expect(response).to redirect_to '/profile'
      end
    end

    context 'given user is not logged in' do
      let(:response) { get "/login" }

      it 'renders :login template' do
        expect(response.status).to eq 200
        expect(response.body).to have_tag(:label, text: 'Username')
        expect(response.body).to have_tag(:label, text: 'Passwort')
        expect(response.body).to have_tag(:input, value: 'Login')
      end
    end
  end

  describe 'POST login' do
    context 'given credentials are valid' do
      let(:response) { post "/login", { username: 'john',
                                        password: 'johnldap'} }
      it 'redirects to /profile' do
        expect(response).to redirect_to '/profile'
      end
    end

    context 'given credentials are not correct' do
      let(:response) { post "/login", { username: 'john',
                                        password: 'thisiswrong'} }
      include_examples 'redirects to /login'
      it 'sends back error message' do
        expect(response.location).to match 'Wrong username or password'
      end
    end
  end

  context 'GET /profile' do
    context 'given user is logged in' do
      let(:response) { get '/profile', {}, 'rack.session' => session_data }
      it 'redirects to /profile/:username' do
        expect(response).to redirect_to '/profile/john'
      end
    end
    context 'given user is  not logged in' do
      let(:response) { get '/profile' }
      include_examples 'redirects to /login'
    end
  end

  context 'GET /profile/:username' do
    context 'given user is logged in' do
      let(:response) { get '/profile/john', {}, 'rack.session' => session_data }
      it 'redirects to /profile/:username' do
        expect(response.status).to eq 200
        expect(response.body).to have_tag(:a,
                                          href: '/username/john/password',
                                          text: 'Passwort ändern')
        expect(response.body).to have_tag(:a, href: '/logout', text: 'Logout')
      end
    end

    context 'given user is not logged in' do
      let(:response) { get '/profile' }
      include_examples 'redirects to /login'
    end

    context 'given access is forbidden' do
      let(:response) { get '/profile/anotheruser',
                           {},
                           'rack.session' => session_data }
      include_examples 'raises 403'
    end
  end

  context 'GET /logout' do
    let(:response) { get '/logout', {}, 'rack.session' => session_data }
    include_examples 'redirects to /login'
  end

  context 'GET /profile/:username/password' do
    context 'given user is logged in' do
      let(:response) { get '/profile/john/password',
                           {},
                           'rack.session' => session_data }
      it 'renders :password template' do
        expect(response.status).to eq 200
        expect(response.body).to have_tag(:label, text: 'Neues Passwort *')
        expect(response.body).to have_tag(:label, text: 'Neues Passwort bestätigen *')
        expect(response.body).to have_tag(:input, value: 'Passwort ändern')
      end
    end

    context 'given user is not logged in' do
      let(:response) { get '/profile/john/password' }
      include_examples 'redirects to /login'
    end

    context 'given access is forbidden' do
      let(:response) { get '/profile/anotheruser/password',
                           {},
                           'rack.session' => session_data }
      include_examples 'raises 403'
    end
  end

  context 'POST /profile/:username/password' do
    describe 'given an empty password' do
      let(:response) { post '/profile/john/password',
                            { current_password: 'johnldap ',
                              new_password: '',
                              new_password_confirmation: '' },
                            'rack.session' => session_data }
      it 'redirects to password form' do
        expect(response).to redirect_to '/profile/john/password'
        expect(response.location).to match 'Password and confirmation do not match'
      end
    end
    context 'given not matching passwords' do
      let(:response) { post '/profile/john/password',
                            { current_password: 'johnldap',
                              new_password: 'newandshiny',
                              new_password_confirmation: 'butwrong' },
                            'rack.session' => session_data }
      it 'redirects to password form' do
        expect(response).to redirect_to '/profile/john/password'
        expect(response.location).to match 'Password and confirmation do not match'
      end
    end
    describe 'given wrong password' do
      let(:response) { post '/profile/john/password',
                            { current_password: 'foobar',
                              new_password: 'newandshiny',
                              new_password_confirmation: 'newandshiny' },
                            'rack.session' => session_data }
      it 'redirects to password form' do
        expect(response).to redirect_to '/profile/john/password'
        expect(response.location).to match 'Password is wrong'
      end
    end
    describe 'given correct passwords' do
      let(:response) { post '/profile/john/password',
                            { current_password: 'johnldap',
                              new_password: 'newandshiny',
                              new_password_confirmation: 'newandshiny' },
                            'rack.session' => session_data }
      it 'redirects to password form' do
        expect(response).to redirect_to '/profile/john'
        expect(response.location).to match 'Password updated'
      end
      it "resets the test db" do
        post '/profile/john/password',
             { current_password: 'newandshiny',
               new_password: 'johnldap',
               new_password_confirmation: 'johnldap' },
             'rack.session' => session_data
      end
    end
  end

  context 'GET /new' do
    context 'given registration is closed' do
      let(:response) { get '/new' }

      it 'renders the :new template' do
        ENV['REGISTRATION_OPEN'] = 'false'
        expect(response.status).to eq 200
        expect(response.body).to have_tag(:p,
                                          text: 'Neuanmeldung zur Zeit nicht möglich')
        expect(response.body).to have_tag(:a, href: '/login', text: 'Zurück')
        ENV['REGISTRATION_OPEN'] = 'true'
      end
    end

    context 'given registration is open' do
      let(:response) { get '/new' }

      it 'renders the :new template' do
        expect(response.status).to eq 200
        expect(response.body).to have_tag(:label, text: 'Voller Name *')
        expect(response.body).to have_tag(:label, text: 'Username *')
        expect(response.body).to have_tag(:label, text: 'Email *')
        expect(response.body).to have_tag(:a, href: '/login', text: 'Zurück')
      end
    end
  end

  context 'POST /create' do
    context 'given registration is closed' do
      let(:response) { post '/create', new_account_data }

      it 'raises 403 Error' do
        ENV['REGISTRATION_OPEN'] = 'false' # only relevant to one test
        expect(response.status).to eq 403
        expect(response.body).to match 'Error 403'
        ENV['REGISTRATION_OPEN'] = 'true'
      end
    end

    context 'given passwords do not match' do
      wrong_data = new_account_data
      wrong_data[:password_confirmation] = 'foo'
      let(:response) { post '/create', wrong_data }

      it 'redirects to /new' do
        expect(response).to redirect_to '/new'
        expect(response.location).to match 'status=Error&message=Password is either empty or does not match'
      end
    end

    context 'given username is already taken' do
      it 'redirects'
    end
    context 'given data is valid' do
      it 'redirects'
    end
  end


  context 'GET /forgot_password' do
    let(:response) { get '/forgot_password' }

    it 'renders the :forgot_password template' do
      expect(response.status).to eq 200
      expect(response.body).to have_tag(:h2,
                                        text: 'Password zurücksetzen')
      expect(response.body).to have_tag(:input, value: 'Passwort zurücksetzen')
    end
  end

  context 'POST /forgot_password' do
    context 'Email exists' do
      right_data = {}
      right_data[:email] = 'te@example.org'
      let(:response) { post '/forgot_paddword', right_data }

      it 're-renders the form with success message' do
      end
    end

    context 'Email does not exist' do
      wrong_data = {}
      wrong_data[:email] = 'foobi@doobi.wrong'
      let(:response) { post '/forgot_paddword', wrong_data }

      it 're-renders the form with success message' do
      end
    end
  end

  context 'GET /reset_password' do
    context 'with a correct token' do
      it 'renders :reset_password view'
    end

    context 'with expired token' do
      it 'renders :error_reset_password view'
      it 'destroys the token'
    end

    context 'with plain wrong token' do
      it 'renders :error_reset_password view'
    end
  end

  context 'POST /reset_password' do
    context 'passwords match' do
      it 'sets new password' do
      end
      it 'destroys the token' do

      end
    end
    context 'passwords do not match' do
      it 're-renders form with message' do

      end
    end
  end

  context 'POST /delete_account' do
    it 'deletes the user and redirects to login' do

    end
  end
end

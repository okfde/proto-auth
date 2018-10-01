# coding: utf-8
require "spec_helper"

describe App do
  let(:app) { App.new }

  session_data = { user_dn: 'uid=fakeuser,ou=people,dc=fake,dc=xyz',
                   uid: 'fakeuser' }
  new_account_data = { full_name: 'fakey mcfake',
                       user_name: 'fakeuser',
                       password: 'apassword',
                       password_confirmation: 'apassword',
                       email: 'email@example.com' }

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

  context 'POST login' do
    context 'given credentials are valid' do
      let(:response) { post "/login", { username: 'fakeuser',
                                        password: 'finepassword'} }
      pending 'redirects to /profile' do
        expect(response).to redirect_to '/profile'
      end
    end

    context 'given credentials are not correct' do
      let(:response) { post "/login", { username: 'fakeuser',
                                        password: 'finepassword'} }
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
        expect(response).to redirect_to '/profile/fakeuser'
      end
    end
    context 'given user is  not logged in' do
      let(:response) { get '/profile' }
      include_examples 'redirects to /login'
    end
  end

  context 'GET /profile/:username' do
    context 'given user is logged in' do
      let(:response) { get '/profile/fakeuser', {}, 'rack.session' => session_data }
      it 'redirects to /profile/:username' do
        expect(response.status).to eq 200
        expect(response.body).to have_tag(:a,
                                          href: '/username/fakeuser/password',
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
      let(:response) { get '/profile/fakeuser/password',
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
      let(:response) { get '/profile/fakeuser/password' }
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
    context 'given an empty password' do
      let(:response) { post '/profile/fakeuser/password',
                            { password: 'currentpw',
                              new_password: '',
                              new_password_confirmation: '' },
                            'rack.session' => session_data }
      it 'redirects to password form' do
        expect(response).to redirect_to '/profile/fakeuser/password'
        expect(response.location).to match 'Password and confirmation do not match'
      end
    end
    context 'given not matching passwords' do
      let(:response) { post '/profile/fakeuser/password',
                            { password: 'currentpw',
                              new_password: 'new',
                              new_password_confirmation: 'new and shiny' },
                            'rack.session' => session_data }
      it 'redirects to password form' do
        expect(response).to redirect_to '/profile/fakeuser/password'
        expect(response.location).to match 'Password and confirmation do not match'
      end
    end
    context 'given wrong password' do
      it 'redirects'
    end
    context 'given correct passwords' do
      it 'redirects'
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
end

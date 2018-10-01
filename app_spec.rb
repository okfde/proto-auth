require "spec_helper"

describe App do
  let(:app) { App.new }

  session_data = { user_dn: '1234', uid: '1234' }

  context 'GET /' do
    context 'given user is logged in' do
      let(:response) { get '/', {}, 'rack.session' => session_data }
      it 'redirects to /profile' do
        expect(response.status).to eq 302
        expect(response.location).to match '/profile'
      end
    end

    context 'given user is not logged in' do
      let(:response) { get "/" }
      it 'redirects to /login' do
        expect(response.status).to eq 302
        expect(response.location).to match '/login'
      end
    end
  end

  context 'GET /login' do
    context 'given user is logged in' do
      let(:response) { get '/login', {}, 'rack.session' => session_data }
      it 'redirects to /profile' do
        expect(response.status).to eq 302
        expect(response.location).to match '/profile'
      end
    end

    context 'given user is not logged in' do
      let(:response) { get "/login" }

      it 'renders :login template' do
        expect(response.status).to eq 200
        expect(response.body).to include 'Neuen Account anlegen'
      end
    end
  end

  context 'POST login' do
    context 'given credentials are valid' do
      it 'redirects'
    end
    context 'given credentials are not correct' do
      it 'redirects'
    end
  end

  context 'GET /profile' do
    context 'given user is logged in' do
      it 'redirects'
    end
    context 'given user is  not logged in' do
      it 'redirects'
    end
  end

  context 'GET /profile/:username' do
    context 'given user is logged in' do
      it 'renders'
    end
    context 'given user is not logged in' do
      it 'redirects'
    end
    context 'given access is forbidden' do
      it 'raises'
    end
  end

  context 'GET /logout' do
    it 'redirects'
  end

  context 'GET /profile/:username/password' do
    context 'given user is logged in' do
      it 'renders'
    end
    context 'given user is not logged in' do
      it 'redirects'
    end
    context 'given access is forbidden' do
      it 'raises'
    end
  end

  context 'POST /profile/:username/password' do
    context 'given an empty password' do
      it 'redirects'
    end
    context 'given not matching passwords' do
      it 'redirects'
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
      it 'renders'
    end
    context 'given registration is open' do
      it 'renders'
    end
  end

  context 'POST /create' do
    context 'given registration is closed' do
      it 'raises'
    end
    context 'given passwords do not match' do
      it 'redirects'
    end
    context 'given username is already taken' do
      it 'redirects'
    end
    context 'given data is valid' do
      it 'redirects'
    end
  end
end

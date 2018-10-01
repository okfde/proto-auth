require "spec_helper"

describe App do
  let(:app) { App.new }

  context 'GET /' do
    context 'given user is logged in' do
      it 'redirects'
    end
    context 'given user is not logged in' do
      it 'redirects'
    end
  end

  context 'GET /login' do
    context 'given user is logged in' do
      it 'redirects'
    end
    context 'given user is not logged in' do
      it 'renders'
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

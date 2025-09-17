require 'rails_helper'

RSpec.describe 'Basic Authentication', type: :request do
  describe 'when accessing dashboard' do
    context 'when not in production' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::EnvironmentInquirer.new('test'))
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('BASIC_AUTH_USERNAME').and_return('testuser')
        allow(ENV).to receive(:[]).with('BASIC_AUTH_PASSWORD').and_return('testpass')
      end

      it 'allows access without basic auth' do
        get '/'
        expect(response).to have_http_status(:success)
      end
    end

    context 'when in production with auth credentials missing' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::EnvironmentInquirer.new('production'))
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('BASIC_AUTH_USERNAME').and_return(nil)
        allow(ENV).to receive(:[]).with('BASIC_AUTH_PASSWORD').and_return(nil)
      end

      it 'returns service unavailable error' do
        get '/'
        expect(response).to have_http_status(:service_unavailable)
        expect(response.body).to include('Configuration Error: Basic authentication credentials must be set in production')
      end
    end

    context 'when in production with partial auth credentials' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::EnvironmentInquirer.new('production'))
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('BASIC_AUTH_USERNAME').and_return('testuser')
        allow(ENV).to receive(:[]).with('BASIC_AUTH_PASSWORD').and_return(nil)
      end

      it 'returns service unavailable error' do
        get '/'
        expect(response).to have_http_status(:service_unavailable)
        expect(response.body).to include('Configuration Error: Basic authentication credentials must be set in production')
      end
    end

    context 'when in production with auth credentials set' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::EnvironmentInquirer.new('production'))
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('BASIC_AUTH_USERNAME').and_return('testuser')
        allow(ENV).to receive(:[]).with('BASIC_AUTH_PASSWORD').and_return('testpass')
      end

      context 'without authorization header' do
        it 'returns 401 and requests authentication' do
          get '/'
          expect(response).to have_http_status(:unauthorized)
          expect(response.headers['WWW-Authenticate']).to eq('Basic realm="Application"')
        end
      end

      context 'with valid credentials' do
        it 'allows access' do
          credentials = ActionController::HttpAuthentication::Basic.encode_credentials('testuser', 'testpass')
          get '/', headers: { 'HTTP_AUTHORIZATION' => credentials }
          expect(response).to have_http_status(:success)
        end
      end

      context 'with invalid username' do
        it 'returns 401' do
          credentials = ActionController::HttpAuthentication::Basic.encode_credentials('wronguser', 'testpass')
          get '/', headers: { 'HTTP_AUTHORIZATION' => credentials }
          expect(response).to have_http_status(:unauthorized)
          expect(response.headers['WWW-Authenticate']).to eq('Basic realm="Application"')
        end
      end

      context 'with invalid password' do
        it 'returns 401' do
          credentials = ActionController::HttpAuthentication::Basic.encode_credentials('testuser', 'wrongpass')
          get '/', headers: { 'HTTP_AUTHORIZATION' => credentials }
          expect(response).to have_http_status(:unauthorized)
          expect(response.headers['WWW-Authenticate']).to eq('Basic realm="Application"')
        end
      end

      context 'with malformed authorization header' do
        it 'returns 401' do
          get '/', headers: { 'HTTP_AUTHORIZATION' => 'Basic malformed' }
          expect(response).to have_http_status(:unauthorized)
          expect(response.headers['WWW-Authenticate']).to eq('Basic realm="Application"')
        end
      end
    end

    context 'when accessing API endpoints in production' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::EnvironmentInquirer.new('production'))
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('BASIC_AUTH_USERNAME').and_return(nil)
        allow(ENV).to receive(:[]).with('BASIC_AUTH_PASSWORD').and_return(nil)
      end

      it 'skips authentication for API endpoints' do
        post '/api/v1/test_runs', params: { test_data: 'sample' }
        expect(response).to_not have_http_status(:service_unavailable)
        # It should return 401 from the API authentication, not from basic auth
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to_not include('Configuration Error')
      end
    end

  end
end
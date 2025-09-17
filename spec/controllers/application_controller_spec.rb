require 'rails_helper'

RSpec.describe 'Basic Authentication', type: :request do
  describe 'when accessing dashboard' do
    context 'when not in production' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::EnvironmentInquirer.new('test'))
        allow(ENV).to receive(:[]).with('BASIC_AUTH_USERNAME').and_return('testuser')
        allow(ENV).to receive(:[]).with('BASIC_AUTH_PASSWORD').and_return('testpass')
        allow(ENV).to receive(:[]).and_call_original
      end

      it 'allows access without basic auth' do
        get '/'
        expect(response).to have_http_status(:success)
      end
    end

    context 'when auth credentials not set' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::EnvironmentInquirer.new('production'))
        allow(ENV).to receive(:[]).with('BASIC_AUTH_USERNAME').and_return(nil)
        allow(ENV).to receive(:[]).with('BASIC_AUTH_PASSWORD').and_return(nil)
        allow(ENV).to receive(:[]).and_call_original
      end

      it 'allows access without basic auth' do
        get '/'
        expect(response).to have_http_status(:success)
      end
    end
  end
end
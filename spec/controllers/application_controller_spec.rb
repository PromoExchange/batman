require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'Routing' do
    it 'should route GET /ping to the application controller with :ping action' do
      should route(:get, '/ping').to(controller: :application, action: :ping)
    end
  end

  describe "GET 'ping'" do
    before :each do
      get :ping, format: :json
    end

    it 'returns http success' do
      should respond_with 200
    end
  end
end

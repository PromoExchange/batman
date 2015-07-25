require 'rails_helper'
require 'spree_shared'

describe 'Logo API' do
  include_context 'spree_shared'

  xit 'must require an api key' do
    logo = FactoryGirl.create(:logo)

    get "/api/logos/#{logo.id}"

    expect(response).to have_http_status(401)
  end

  xit 'should get a list of logos' do
    FactoryGirl.create_list(:logo, 10)

    get '/api/logos', nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(10)
  end

  xit 'should get a single logo' do
    logo = FactoryGirl.create(:logo)

    get "/api/logos/#{logo.id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end

  xit 'should create a new logo' do
    logo = FactoryGirl.build(:logo)

    mess = logo.to_json

    post '/api/logos', mess, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end

  xit 'should update an existing logo'
  xit 'should delete a logo'
end

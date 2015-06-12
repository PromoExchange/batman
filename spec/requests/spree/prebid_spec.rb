require 'rails_helper'
require 'spree_shared'

describe 'Prebids API' do
  include_context 'spree_shared'

  it 'should require an api key' do
    prebid = FactoryGirl.create(:prebid)

    get "/api/prebids/#{prebid.id}"

    expect(response).to have_http_status(401)
  end

  it 'should get a list of prebids' do
    FactoryGirl.create_list(:prebid, 10)

    get '/api/prebids', nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(10)
  end

  it 'should get a page of prebids' do
    FactoryGirl.create_list(:prebid, 10)

    get '/api/prebids?page=2&per_page=3', nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(3)
  end

  it 'should get a single prebid' do
    prebid = FactoryGirl.create(:prebid, description: 'description get')

    get "/api/prebids/#{prebid.id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['description']).to eq('description get')
  end

  it 'should update a prebid' do
    prebid = FactoryGirl.create(:prebid, description: 'put subject')

    put "/api/prebids/#{prebid.id}", prebid.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['description']).to eq('put subject')
  end

  it 'should not create a duplicate prebid' do |member|
    prebid = FactoryGirl.create(:prebid)

    post '/api/prebids', prebid.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to have_http_status(422)
  end

  it 'should create a prebid' do
    prebid = FactoryGirl.build(:prebid, description: 'posty description')

    post '/api/prebids', prebid.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['description']).to eq('posty description')
  end

  it 'should delete a prebid' do
    prebid = FactoryGirl.create(:prebid)

    delete "/api/prebids/#{prebid.id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end
end

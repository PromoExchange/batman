require 'rails_helper'
require 'spree_shared'

describe 'Favorites API' do
  include_context 'spree_shared'

  it 'should require an api key' do
    favorite = FactoryGirl.create(:favorite)

    get "/api/favorites/#{favorite.id}"

    expect(response).to have_http_status(401)
  end

  it 'should get a list of favorites' do
    FactoryGirl.create_list(:favorite, 10)

    get '/api/favorites', nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(10)
  end

  it 'should get a page of favorites' do
    FactoryGirl.create_list(:favorite, 10)

    get '/api/favorites?page=2&per_page=3', nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(3)
  end

  it 'should get a single favorite' do
    favorite = FactoryGirl.create(:favorite)

    get "/api/favorites/#{favorite.id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end

  it 'should update a favorite' do
    favorite = FactoryGirl.create(:favorite, buyer_id: 1)

    put "/api/favorites/#{favorite.id}", favorite.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['buyer_id']).to eq(1)
  end

  it 'should create a favorite' do
    favorite = FactoryGirl.build(:favorite)

    post '/api/favorites', favorite.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end

  it 'should not create a duplicate favorite' do
    favorite = FactoryGirl.create(:favorite)

    post '/api/favorites', favorite.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to have_http_status(422)
  end

  it 'should deletes a favorite' do
    favorite = FactoryGirl.create(:favorite)

    delete "/api/favorites/#{favorite.id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end
end

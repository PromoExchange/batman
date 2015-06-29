require 'rails_helper'
require 'spree_shared'

describe 'Auctions API' do
  include_context 'spree_shared'

  it 'should require an api key' do
    auction = FactoryGirl.create(:auction)

    get "/api/auctions/#{auction.id}"

    expect(response).to have_http_status(401)
  end

  it 'should get a list of auctions' do
    FactoryGirl.create_list(:auction, 10)

    get '/api/auctions', nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(10)
  end

  it 'should get a page of auctions' do
    FactoryGirl.create_list(:auction, 10)

    get '/api/auctions?page=2&per_page=3', nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(3)
  end

  it 'should get a single auction' do
    auction = FactoryGirl.create(:auction)

    get "/api/auctions/#{auction.id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end

  it 'should update an auction' do
    auction = FactoryGirl.create(:auction, quantity: 10000)

    put "/api/auctions/#{auction.id}", auction.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['quantity']).to eq(10000)
  end

  it 'should not create a duplication auction' do
    auction = FactoryGirl.create(:auction)

    post '/api/auctions', auction.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to have_http_status(422)
  end

  it 'should create an auction' do
    auction = FactoryGirl.build(:auction, quantity: 10232)

    post '/api/auctions', auction.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['quantity']).to eq(10232)
  end

  it 'should delete an auction' do
    auction = FactoryGirl.create(:auction)

    delete "/api/auctions/#{auction.id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end
end

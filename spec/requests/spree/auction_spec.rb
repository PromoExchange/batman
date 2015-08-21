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

  it 'should not get a list of open auctions' do
    FactoryGirl.create_list(:auction, 10)

    get '/api/auctions?status=open', nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(10)
  end

  it 'should get a list of auctions with multiple stati' do
    FactoryGirl.create(:auction)
    FactoryGirl.create(:waiting_auction)

    get '/api/auctions?status=open,waiting', nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(2)
  end

  it 'should not get a list of open auctions' do
    FactoryGirl.create(:waiting_auction)

    get '/api/auctions?status=open', nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(0)
  end

  it 'should get an auction for a buyer' do
    auction = FactoryGirl.create(:auction)

    get "/api/auctions?buyer_id=#{auction.buyer_id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(1)
  end

  it 'should get a list of waiting auctions' do
    FactoryGirl.create_list(:waiting_auction, 10)

    get '/api/auctions?status=waiting', nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(10)
  end

  it 'should get a list of my auctions' do
    auction = FactoryGirl.create(:auction)

    get "/api/auctions?buyer_id=#{auction.buyer_id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(1)
  end

  it 'should not get a list of my auctions' do
    FactoryGirl.create_list(:auction, 10)

    get '/api/auctions?buyer_id=12312133', nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(0)
  end

  it 'should get a single auction' do
    auction = FactoryGirl.create(:auction)

    get "/api/auctions/#{auction.id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end

  it 'should update an auction' do
    auction = FactoryGirl.create(:auction, quantity: 1000)

    put "/api/auctions/#{auction.id}", auction.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['quantity']).to eq(1000)
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

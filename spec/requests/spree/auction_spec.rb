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

    get '/api/auctions', nil, 'X-Spree-Token' => current_api_user.spree_api_key.to_s

    expect(response).to be_success
    expect(json.length).to eq(10)
  end

  it 'should get a list of open auctions' do
    FactoryGirl.create_list(:auction, 10)
    FactoryGirl.create_list(:waiting_confirmation, 5)

    get '/api/auctions', { state: 'open' }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s

    expect(response).to be_success
    expect(json.length).to eq(10)
  end

  it 'should get a list of auctions with multiple states' do
    FactoryGirl.create(:auction)
    FactoryGirl.create(:waiting_confirmation)
    FactoryGirl.create(:cancelled)

    get '/api/auctions', { state: 'open,waiting_confirmation' }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s

    expect(response).to be_success
    expect(json.length).to eq(2)
  end

  it 'should not get a list of open auctions' do
    FactoryGirl.create(:waiting_confirmation)

    get '/api/auctions', { state: 'open' }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s

    expect(response).to be_success
    expect(json.length).to eq(0)
  end

  it 'should get an auction for a buyer' do
    auction = FactoryGirl.create(:auction)
    FactoryGirl.create_list(:auction, 10)

    get '/api/auctions', { buyer_id: auction.buyer_id }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s

    expect(response).to be_success
    expect(json.length).to eq(1)
  end

  it 'should get a list of completed auctions' do
    FactoryGirl.create_list(:waiting_confirmation, 10)
    FactoryGirl.create(:auction)
    FactoryGirl.create(:cancelled)

    get '/api/auctions', { state: 'waiting_confirmation' }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s

    expect(response).to be_success
    expect(json.length).to eq(10)
  end

  it 'should get a list of my auctions' do
    auction = FactoryGirl.create(:auction)
    FactoryGirl.create_list(:waiting_confirmation, 10)

    get '/api/auctions', { buyer_id: auction.buyer_id }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s

    expect(response).to be_success
    expect(json.length).to eq(1)
  end

  it 'should not get a list of my auctions' do
    FactoryGirl.create_list(:auction, 10)

    get '/api/auctions', { buyer_id: '12312133' }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s

    expect(response).to be_success
    expect(json.length).to eq(0)
  end

  it 'should get a single auction' do
    auction = FactoryGirl.create(:auction)

    get "/api/auctions/#{auction.id}", nil, 'X-Spree-Token' => current_api_user.spree_api_key.to_s

    expect(response).to be_success
  end

  it 'should update an auction' do
    auction = FactoryGirl.create(:auction, quantity: 1000)

    put "/api/auctions/#{auction.id}", auction.to_json, 'X-Spree-Token' => current_api_user.spree_api_key.to_s

    expect(response).to be_success
    expect(json['quantity']).to eq(1000)
  end

  it 'should not create a duplication auction' do
    auction = FactoryGirl.create(:auction)

    post '/api/auctions', auction.to_json, 'X-Spree-Token' => current_api_user.spree_api_key.to_s

    expect(response).to have_http_status(422)
  end

  it 'should create an auction' do
    auction = FactoryGirl.build(:auction, quantity: 10232)

    post '/api/auctions', auction.to_json, 'X-Spree-Token' => current_api_user.spree_api_key.to_s

    expect(response).to be_success
    expect(json['quantity']).to eq(10232)
  end

  it 'should delete an auction' do
    auction = FactoryGirl.create(:auction)

    delete "/api/auctions/#{auction.id}", nil, 'X-Spree-Token' => current_api_user.spree_api_key.to_s

    expect(response).to be_success
  end

  it 'should add a tracking number' do
    auction = FactoryGirl.create(:auction)

    post "/api/auctions/#{auction.id}/tracking",
      { tracking_number: '1234', agent_type: 'ups', format: 'json' },
      'X-Spree-Token' => current_api_user.spree_api_key.to_s

    a = Spree::Auction.find(auction.id)

    expect(a.tracking_number).to eq('1234')
  end
end

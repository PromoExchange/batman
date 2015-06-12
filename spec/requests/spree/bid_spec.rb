require 'rails_helper'
require 'spree_shared'

describe 'Bids API' do
  include_context 'spree_shared'

  it 'must require an api key (nested)' do
    auction = FactoryGirl.build(:auction)
    bid = FactoryGirl.build(:bid)
    bid.auction_id = auction.id
    auction.save

    get "/api/auctions/#{auction.id}/bids"

    expect(response).to have_http_status(401)
  end

  it 'must require an api key (root)' do
    auction = FactoryGirl.build(:auction)
    bid = FactoryGirl.build(:bid)
    bid.auction_id = auction.id
    auction.save

    get "/api/bids"

    expect(response).to have_http_status(401)
  end

  it 'should get a list of bids (nested)' do
    auction = FactoryGirl.create(:auction_with_bids)

    get "/api/auctions/#{auction.id}/bids", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(10)
  end

  it 'should get a list of bids (root)' do
    FactoryGirl.create_list(:bid,5)

    get "/api/bids", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(5)
  end

  it 'should gets a page of bids' do
    FactoryGirl.create_list(:bid, 10)

    get '/api/bids?page=2&per_page=3', nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(3)
  end

  it 'should get a single bid (nested)' do
    auction = FactoryGirl.create(:auction_with_bids)

    get "/api/auctions/#{auction.id}/bids/#{auction.bids[0].id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['description']).to eq(auction.bids[0].description)
  end

  it 'should get a single bid (root)' do
    bid = FactoryGirl.create(:bid, description: 'description')

    get "/api/bids/#{bid.id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['description']).to eq(bid.description)
  end

  xit 'should update a bid (nested)' do
    auction = FactoryGirl.create(:auction)
    bid = FactoryGirl.create(:bid, description: 'created description')
    bid.description = 'put description'
    bid.bid = 11.11

    put "/api/auctions/#{auction.id}/bids/#{bid.id}", bid.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success

    b = Spree::Bid.find(bid.id)
    expect(b.description).to eq('put description')
    expect(b.bid).to eq(11.11)
  end

  xit 'should update a bid (root)' do
    bid = FactoryGirl.create(:bid, description: 'created description')
    bid.description = 'put description'
    bid.bid = 11.11

    put "/api/bids/#{bid.id}", bid.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success

    b = Spree::Bid.find(bid.id)
    expect(b.description).to eq('put description')
    expect(b.bid).to eq(11.11)
  end

  it 'should create a bid (nested)' do
    auction = FactoryGirl.create(:auction)
    bid = FactoryGirl.build(:bid, description: 'posty description')

    post "/api/auctions/#{auction.id}/bids", bid.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['description']).to eq('posty description')
  end

  it 'should not create a duplicate bid (nested)' do
    auction = FactoryGirl.create(:auction)
    bid = FactoryGirl.create(:bid)

    post "/api/auctions/#{auction.id}/bids", bid.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to have_http_status(422)
  end

  it 'should create a bid (root)' do
    bid = FactoryGirl.build(:bid, description: 'posty description')

    post "/api/bids", bid.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['description']).to eq('posty description')
  end

  it 'should not create a duplicate bid (root)' do
    bid = FactoryGirl.create(:bid)

    post "/api/bids", bid.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to have_http_status(422)
  end

  it 'should delete a bid (nested)' do
    auction = FactoryGirl.create(:auction_with_bids)

    delete "/api/auctions/#{auction.id}/bids/#{auction.bids[0].id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    a = Spree::Auction.find(auction.id)
    expect(a.bids.length).to eq(9)
  end

  it 'should delete a bid (root)' do
    bid = FactoryGirl.create(:bid)

    delete "/api/bids/#{bid.id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end
end

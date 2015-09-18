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

    get '/api/bids'

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

  it 'should get a single bid (nested)' do
    auction = FactoryGirl.create(:auction_with_bids)

    get "/api/auctions/#{auction.id}/bids/#{auction.bids[0].id}",
      nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end

  it 'should find one auction' do
    auctions = FactoryGirl.create_list(:auction,10)

    get "/api/bids?auction_id=#{auctions[2].id}",
      nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end

  it 'should get a single bid (root)' do
    bid = FactoryGirl.create(:bid)

    get "/api/bids/#{bid.id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end

  it 'should update a bid (nested)' do
    auction = FactoryGirl.create(:auction)
    bid = FactoryGirl.create(:bid)

    put "/api/auctions/#{auction.id}/bids/#{bid.id}", bid.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end

  it 'should update a bid (root)' do
    bid = FactoryGirl.create(:bid)

    put "/api/bids/#{bid.id}", bid.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end

  it 'should create a bid (nested)' do
    auction = FactoryGirl.create(:auction)
    bid = FactoryGirl.build(:bid)

    post "/api/auctions/#{auction.id}/bids", bid.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end

  xit 'should not create a duplicate bid (nested)' do
    auction = FactoryGirl.create(:auction)
    bid = FactoryGirl.create(:bid)

    post "/api/auctions/#{auction.id}/bids", bid.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to have_http_status(422)
  end

  it 'should create a bid (root)' do
    bid = FactoryGirl.build(:bid)

    post '/api/bids', bid.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end

  xit 'should not create a duplicate bid (root)' do
    bid = FactoryGirl.create(:bid)

    post '/api/bids', bid.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to have_http_status(422)
  end

  it 'should delete a bid (nested)' do
    auction = FactoryGirl.create(:auction_with_one_bid)

    delete "/api/auctions/#{auction.id}/bids/#{auction.bids[0].id}",
      nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    a = Spree::Auction.find(auction.id)
    expect(a.bids.length).to eq(1)
  end

  it 'should delete a bid (root)' do
    bid = FactoryGirl.create(:bid)

    delete "/api/bids/#{bid.id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end

  it 'should allow accept bid' do
    bid = FactoryGirl.create(:bid)

    post "/api/bids/#{bid.id}/accept", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    a = Spree::Bid.find(bid.id)
    expect(a.state).to eq('accepted')
  end
end

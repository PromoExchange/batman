require 'rails_helper'

describe 'Auctions API' do
  let(:current_api_user) do
    user = Spree.user_class.new(email: 'spree@example.com',
                                password: 'password')
    user.generate_spree_api_key!
    user
  end

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
    expect(json['description']).to eq(auction.description)
  end

  it 'should update an auction' do
    auction = FactoryGirl.create(:auction, description: 'put description')

    put "/api/auctions/#{auction.id}", auction.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['description']).to eq('put description')
  end

  it 'should create an auction' do
    auction = FactoryGirl.build(:auction, description: 'posty description')

    post '/api/auctions', auction.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['description']).to eq('posty description')
  end

  it 'should delete an auction' do
    auction = FactoryGirl.create(:auction)

    delete "/api/auctions/#{auction.id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end
end

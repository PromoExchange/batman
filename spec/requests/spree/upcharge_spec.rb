require 'rails_helper'
require 'spree_shared'

describe 'Upcharge API' do
  include_context 'spree_shared'

  it 'must require an api key' do
    get "/api/upcharges?product_id=1"
    expect(response).to have_http_status(401)
  end

  xit 'should get a list of upcharges' do
    upcharges = FactoryGirl.create_list(:upcharge_static_product, 10)

    get "/api/upcharges?product_id=#{upcharges[0].id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json.length).to eq(10)
  end

  it 'should get a single upcharge' do
    upcharge = FactoryGirl.create(:upcharge)

    get "/api/upcharges/#{upcharge.id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['id']).to eq(upcharge.id)
  end

  it 'should create an upcharge' do
    upcharge = FactoryGirl.build(:upcharge, value: 'test')

    post '/api/upcharges', upcharge.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['value']).to eq('test')
  end

  it 'should not create a duplicate upcharge' do |member|
    upcharge = FactoryGirl.create(:upcharge)

    post '/api/upcharges', upcharge.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to have_http_status(422)
  end

  it 'should delete an upcharge' do
    upcharge = FactoryGirl.create(:upcharge)

    delete "/api/upcharges/#{upcharge.id}", nil, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
  end

  it 'should update an upcharge' do
    upcharge = FactoryGirl.create(:prebid, description: 'put subject')

    put "/api/prebids/#{upcharge.id}", upcharge.to_json, 'X-Spree-Token': "#{current_api_user.spree_api_key}"

    expect(response).to be_success
    expect(json['description']).to eq('put subject')
  end
end

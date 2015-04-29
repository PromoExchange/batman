require 'rails_helper'

describe "Products API" do
  it 'sends a list of products' do
      FactoryGirl.create_list(:product, 10)

      get '/api/v1/products'

      expect(response).to be_success
      expect(json['messages'].length).to eq(10)
  end

  it 'retrieves a specific message' do
    prod = FactoryGirl.create(:product)
    get "/api/v1/products/#{prod.id}"

    # test for the 200 status-code
    expect(response).to be_success

    # check that the message attributes are the same.
    expect(json['content']).to eq(prod.content)

    # ensure that private attributes aren't serialized
    # expect(json['private_attr']).to eq(nil)
  end
end

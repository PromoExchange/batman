require 'rails_helper'

describe "Products API" do
  it 'retrieves a list of products' do
    FactoryGirl.create_list(:product, 10)

    get '/api/v1/products'

    expect(response).to be_success
    # puts response.body
    json = JSON.parse(response.body)
    expect(json.length).to eq(10)
  end

  # FIXME: When the jbuilder templates work, fix these
  xit 'retrieves a specific message' do
    prod = FactoryGirl.create(:product)
    get "/api/v1/products/#{prod.id}"

    # test for the 200 status-code
    expect(response).to be_success

    # check that the message attributes are the same.
    json = JSON.parse(response.body)
    expect(json).to eq(prod)

    # ensure that private attributes aren't serialized
    # expect(json['private_attr']).to eq(nil)
  end
end

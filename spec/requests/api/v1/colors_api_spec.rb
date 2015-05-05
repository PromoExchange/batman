require 'rails_helper'

describe "Colors API" do
  it 'retrieves a list of colors' do
    FactoryGirl.create_list(:color, 10)

    get '/api/v1/colors'

    expect(response).to be_success
    # puts response.body
    json = JSON.parse(response.body)
    expect(json.length).to eq(10)
  end

  # FIXME: When the jbuilder templates work, fix these
  xit 'retrieves a specific message' do
    color = FactoryGirl.create(:color)
    get "/api/v1/products/#{color.id}"

    # test for the 200 status-code
    expect(response).to be_success

    # check that the message attributes are the same.
    json = JSON.parse(response.body)
    expect(json).to eq(color)

    # ensure that private attributes aren't serialized
    # expect(json['private_attr']).to eq(nil)
  end
end

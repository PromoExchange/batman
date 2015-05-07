require 'rails_helper'

describe "Materials API" do
  it 'retrieves a list of materials' do
    FactoryGirl.create_list(:material, 10)

    get '/api/v1/materials'

    expect(response).to be_success
    # puts response.body
    json = JSON.parse(response.body)
    expect(json.length).to eq(10)
  end

  # FIXME: When the jbuilder templates work, fix these
  xit 'retrieves a specific message' do
    material = FactoryGirl.create(:material)
    get "/api/v1/materials/#{material.id}"

    # test for the 200 status-code
    expect(response).to be_success

    # check that the message attributes are the same.
    json = JSON.parse(response.body)
    expect(json).to eq(material)

    # ensure that private attributes aren't serialized
    # expect(json['private_attr']).to eq(nil)
  end
end

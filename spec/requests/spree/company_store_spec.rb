require 'rails_helper'
require 'spree_shared'

describe 'Company Store API' do
  xit 'should return a list of products' do
    company_store = FactoryGirl.create(:company_store)
    FactoryGirl.create_list(:px_product, 5, company_store: company_store)
    get "/api/company_stores/#{company_store.slug}", 'X-Spree-Token' => current_api_user.spree_api_key.to_s
    expect(response).to have_http_status(200)
    expect(response.json.length).to eq(5)
  end

  xit 'should return a single product' do
    company_store = FactoryGirl.create(:company_store)
    FactoryGirl.create_list(:px_product, 5, company_store: company_store)
    get "/api/company_stores/#{company_store.slug}/#{product.first.id}",
      'X-Spree-Token' => current_api_user.spree_api_key.to_s
    expect(response).to have_http_status(200)
    expect(response.json.length).to eq(1)
  end
end

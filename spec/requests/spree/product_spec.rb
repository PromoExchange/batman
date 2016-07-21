require 'rails_helper'
require 'spree_shared'

describe 'Products API' do
  include_context 'spree_shared'

  it 'must require an api key' do
    product = FactoryGirl.create(:product)
    get "/api/products/#{product.id}/best_price"
    expect(response).to have_http_status(401)
  end

  xit 'must get a best price', focus: true do
    product = FactoryGirl.create(
      :px_product,
      :with_fixed_price_per_item_carton,
      :with_setup_upcharges,
      :with_run_upcharges
    )
    shipping_address = FactoryGirl.create(:address)
    get "/api/products/#{product.id}/best_price",
      {
        id: product.id,
        shipping_address: shipping_address.id,
        shipping_option: Spree::ShippingOption::OPTION[:ups_ground]
      }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
    expect(response).to have_http_status(200)
    expect(json[0]['best_price']).to eq 100.0
    expect(json[0]['delivery_days']).to eq 5
  end
end

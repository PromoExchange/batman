require 'rails_helper'
require 'spree_shared'

describe 'Products API' do
  include_context 'spree_shared'

  it 'must require an api key' do
    product = FactoryGirl.create(:product)
    get "/api/products/#{product.id}/best_price"
    expect(response).to have_http_status(401)
  end

  xit 'must get a best price' do
    product = FactoryGirl.create(
      :px_product,
      :with_setup_upcharges,
      :with_run_upcharges,
      :with_carton
    )
    shipping_address = FactoryGirl.create(:address)
    get "/api/products/#{product.id}/best_price",
      {
        id: product.id,
        shipping_address: shipping_address.id,
        shipping_option: Spree::ShippingOption::OPTION[:ups_ground]
      }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
    expect(response).to have_http_status(200)
    expect(json[0]['best_price']).to eq '675.37'
    expect(json[0]['delivery_days']).to eq 7
  end

  xit 'must get a best price with quantity' do
    product = FactoryGirl.create(
      :px_product,
      :with_setup_upcharges,
      :with_run_upcharges,
      :with_carton
    )
    shipping_address = FactoryGirl.create(:address)
    get "/api/products/#{product.id}/best_price",
      {
        quantity: 300,
        id: product.id,
        shipping_address: shipping_address.id,
        shipping_option: Spree::ShippingOption::OPTION[:ups_ground]
      }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
    expect(response).to have_http_status(200)
    expect(json[0]['best_price']).to eq '6430.74'
    expect(json[0]['delivery_days']).to eq 7
  end

  xit 'must get a best price with fixed shipping per item', focus: true do
    product = FactoryGirl.create(
      :px_product,
      :with_setup_upcharges,
      :with_run_upcharges,
      :with_fixed_price_per_item_carton
    )
    shipping_address = FactoryGirl.create(:address)
    get "/api/products/#{product.id}/best_price",
      {
        id: product.id,
        shipping_address: shipping_address.id,
        shipping_option: Spree::ShippingOption::OPTION[:ups_ground]
      }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
    expect(response).to have_http_status(200)
    expect(json[0]['best_price']).to eq '721.5'
    expect(json[0]['delivery_days']).to eq 7
  end

  xit 'must get a best price with fixed shipping per item with quantity', focus: true do
    product = FactoryGirl.create(
      :px_product,
      :with_setup_upcharges,
      :with_run_upcharges,
      :with_fixed_price_per_item_carton
    )
    shipping_address = FactoryGirl.create(:address)
    get "/api/products/#{product.id}/best_price",
      {
        quantity: 200,
        id: product.id,
        shipping_address: shipping_address.id,
        shipping_option: Spree::ShippingOption::OPTION[:ups_ground]
      }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
    expect(response).to have_http_status(200)
    expect(json[0]['best_price']).to eq '4782.0'
    expect(json[0]['delivery_days']).to eq 7
  end

  xit 'must get a best price with fixed shipping total', focus: true do
    product = FactoryGirl.create(
      :px_product,
      :with_setup_upcharges,
      :with_run_upcharges,
      :with_fixed_price_total_carton
    )
    shipping_address = FactoryGirl.create(:address)
    get "/api/products/#{product.id}/best_price",
      {
        id: product.id,
        shipping_address: shipping_address.id,
        shipping_option: Spree::ShippingOption::OPTION[:ups_ground]
      }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
    expect(response).to have_http_status(200)
    expect(json[0]['best_price']).to eq '759.0'
    expect(json[0]['delivery_days']).to eq 7
  end

  xit 'must get a best price with fixed shipping total with quantity', focus: true do
    product = FactoryGirl.create(
      :px_product,
      :with_setup_upcharges,
      :with_run_upcharges,
      :with_fixed_price_total_carton
    )
    shipping_address = FactoryGirl.create(:address)
    get "/api/products/#{product.id}/best_price",
      {
        quantity: 200,
        id: product.id,
        shipping_address: shipping_address.id,
        shipping_option: Spree::ShippingOption::OPTION[:ups_ground]
      }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
    expect(response).to have_http_status(200)
    expect(json[0]['best_price']).to eq '4382.0'
    expect(json[0]['delivery_days']).to eq 7
  end
end

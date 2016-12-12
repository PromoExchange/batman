require 'rails_helper'
require 'spree_shared'

describe 'Products API' do
  include_context 'spree_shared'

  it 'must require an api key' do
    product = FactoryGirl.create(:product)
    get "/api/products/#{product.id}/best_price"
    expect(response).to have_http_status(401)
  end

  describe 'Can only run locally', need_ups: true do
    it 'must get a best price' do
      product = FactoryGirl.create(
        :px_product,
        :with_setup_upcharges,
        :with_run_upcharges,
        :with_carton
      )
      shipping_address = FactoryGirl.create(:address)
      get "/api/products/#{product.id}/best_price",
        {
          quantity: 25,
          id: product.id,
          shipping_address: shipping_address.id,
          shipping_option: :ups_ground
        }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(200)
      expect((json['best_price'].to_f - 841.02).abs).to be < 0.01
      expect(json['delivery_days']).to eq 12
    end

    it 'must get a best price without parameters' do
      product = FactoryGirl.create(:px_product)
      get "/api/products/#{product.id}/best_price",
        {
        }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(200)
      expect((json['best_price'].to_f - 767.33).abs).to be < 0.01
      expect(json).not_to be_empty
    end

    xit 'must get a best price with a configuration' do
      product = FactoryGirl.create(:px_product)
      shipping_address = FactoryGirl.create(:address)
      get "/api/products/#{product.id}/best_price",
        {
          id: product.id,
          shipping_address: shipping_address.id,
          shipping_option: :ups_ground
        }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(200)
      expect(json).not_to be_empty
      expect(json.length).to eq 5
    end

    xit 'must create a product configuration' do
      product = FactoryGirl.create(:px_product)
      configuration = FactoryGirl.create(:preconfigure)
      shipping_address = FactoryGirl.create(:address)
      post "/api/products/#{product.id}/configure", {
        imprint_method: configuration.imprint_method,
        main_color: configuration.main_color.color,
        custom_pms_colors: configuration.custom_pms_colors,
        address: shipping_address.as_json
      }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(200)
    end

    it 'must get a best price with quantity' do
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
          shipping_option: :ups_ground
        }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(200)
      expect((json['best_price'].to_f - 8005.10).abs).to be < 0.01
      expect(json['delivery_days']).to eq 12
    end

    it 'must get a best price with fixed shipping per item' do
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
          shipping_option: :fixed_price_per_item
        }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(200)
      expect((json['best_price'].to_f - 898.39).abs).to be < 0.01
      expect(json['delivery_days']).to eq 12
    end

    it 'must get a best price with upcharge carton' do
      product = FactoryGirl.create(
        :px_product,
        :with_setup_upcharges,
        :with_run_upcharges,
        :with_upcharge_carton
      )
      shipping_address = FactoryGirl.create(:address)
      product.company_store.buyer.ship_address_id = shipping_address.id
      product.save!
      get "/api/products/#{product.id}/best_price",
        {
          id: product.id,
          purchase:
          {
            shipping_address: shipping_address.id,
            shipping_option: :ups_ground
          }
        }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(200)
      expect((json['best_price'].to_f - 854.85).abs).to be < 0.01
      expect(json['delivery_days']).to eq 12
    end

    it 'must get a best price with fixed shipping per item with quantity' do
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
          shipping_option: :fixed_price_per_item
        }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(200)
      expect((json['best_price'].to_f - 5952.72).abs).to be < 0.01
      expect(json['delivery_days']).to eq 12
    end

    it 'must get a best price with fixed shipping total' do
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
          shipping_option: :fixed_price_total
        }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(200)
      expect((json['best_price'].to_f - 945.07).abs).to be < 0.01
      expect(json['delivery_days']).to eq 12
    end

    it 'must get a best price with fixed shipping total with quantity' do
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
          shipping_option: :fixed_price_total
        }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(200)
      expect((json['best_price'].to_f - 5454.82).abs).to be < 0.01
      expect(json['delivery_days']).to eq 12
    end

    it 'must get a best price with fixed shipping total with quantity express' do
      product = FactoryGirl.create(
        :px_product,
        :with_setup_upcharges,
        :with_run_upcharges,
        :with_carton
      )
      shipping_address = FactoryGirl.create(:address)
      get "/api/products/#{product.id}/best_price",
        {
          quantity: 200,
          id: product.id,
          shipping_address: shipping_address.id,
          shipping_option: :ups_next_day_air
        }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(200)
      expect((json['best_price'].to_f - 5673.72).abs).to be < 0.01
      expect(json['delivery_days']).to eq 8
    end
  end
end

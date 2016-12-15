require 'rails_helper'
require 'spree_shared'

describe 'Products API' do
  include_context 'spree_shared'

  it 'must require an api key' do
    product = FactoryGirl.create(:product)
    post "/api/products/#{product.id}/best_price"
    expect(response).to have_http_status(401)
  end

  describe '(Can only run locally)', need_ups: true do
    it 'must get a best price' do
      product = FactoryGirl.create(
        :px_product,
        :with_setup_upcharges,
        :with_run_upcharges,
        :with_carton
      )
      shipping_address = FactoryGirl.create(:address)
      post "/api/products/#{product.id}/best_price",
        {
          id: product.id,
          purchase: {
            quantity: 25,
            shipping_address: shipping_address.id,
            shipping_option: :ups_ground
          }
        }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(200)
      expect((json['best_price'].to_f - 841.02).abs).to be < 0.01
      expect(json['delivery_days']).to eq 12
    end

    it 'must get a best price without parameters' do
      product = FactoryGirl.create(:px_product)
      post "/api/products/#{product.id}/best_price",
        {
        }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(200)
      expect((json['best_price'].to_f - 767.33).abs).to be < 0.01
      expect(json).not_to be_empty
    end

    it 'must get a best price with a specified address' do
      product = FactoryGirl.create(:px_product)
      post "/api/products/#{product.id}/best_price",
        {
          id: product.id,
          purchase: {
            shipping_address:
            {
              company: 'company',
              firstname: 'test_firstname',
              lastname: 'test_lastname',
              address1: 'address1',
              address2: 'address2',
              city: 'city',
              zipcode: '19020',
              phone: '123-456-7890',
              state_id: 1
            },
            shipping_option: :ups_ground
          }
        }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(200)
      expect((json['best_price'].to_f - 764.59).abs).to be < 0.01
    end

    it 'must get a best price with a specified address and quantity of 1' do
      product = FactoryGirl.create(:px_product)
      post "/api/products/#{product.id}/best_price",
        {
          id: product.id,
          purchase: {
            quantity: 1,
            shipping_address:
            {
              company: 'company',
              firstname: 'test_firstname',
              lastname: 'test_lastname',
              address1: 'address1',
              address2: 'address2',
              city: 'city',
              zipcode: '19020',
              phone: '123-456-7890',
              state_id: 1
            },
            shipping_option: :ups_ground
          }
        }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(200)
      expect((json['best_price'].to_f - 43.86).abs).to be < 0.01
    end

    it 'must get a best price with a specified address and quantity of 1 and :with_less_than_minimum' do
      product = FactoryGirl.create(:px_product, :with_less_than_minimum)
      post "/api/products/#{product.id}/best_price",
        {
          id: product.id,
          purchase: {
            quantity: 1,
            shipping_address:
            {
              company: 'company',
              firstname: 'test_firstname',
              lastname: 'test_lastname',
              address1: 'address1',
              address2: 'address2',
              city: 'city',
              zipcode: '19020',
              phone: '123-456-7890',
              state_id: 1
            },
            shipping_option: :ups_ground
          }
        }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(200)
      expect((json['best_price'].to_f - 118.55).abs).to be < 0.01
    end

    it 'must get a best price with a specified address, quantity of 1 and pms_color of 1' do
      product = FactoryGirl.create(:px_product, :with_setup_upcharges)
      post "/api/products/#{product.id}/best_price",
        {
          id: product.id,
          purchase: {
            quantity: 1,
            custom_pms_colors: '123',
            shipping_address:
            {
              company: 'company',
              firstname: 'test_firstname',
              lastname: 'test_lastname',
              address1: 'address1',
              address2: 'address2',
              city: 'city',
              zipcode: '19020',
              phone: '123-456-7890',
              state_id: 1
            },
            shipping_option: :ups_ground
          }
        }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(200)
      expect((json['best_price'].to_f - 106.10).abs).to be < 0.01
    end

    it 'must get a best price with a specified address, quantity of 1 and pms_color of 2' do
      product = FactoryGirl.create(:px_product, :with_setup_upcharges)
      post "/api/products/#{product.id}/best_price",
        {
          id: product.id,
          purchase: {
            quantity: 1,
            custom_pms_colors: '123,456',
            shipping_address:
            {
              company: 'company',
              firstname: 'test_firstname',
              lastname: 'test_lastname',
              address1: 'address1',
              address2: 'address2',
              city: 'city',
              zipcode: '19020',
              phone: '123-456-7890',
              state_id: 1
            },
            shipping_option: :ups_ground
          }
        }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(200)
      expect((json['best_price'].to_f - 168.34).abs).to be < 0.01
    end

    it 'must return an address error with an invalid address' do
      product = FactoryGirl.create(:px_product, :with_run_upcharges)
      post "/api/products/#{product.id}/best_price",
        {
          id: product.id,
          purchase: {
            quantity: 1,
            custom_pms_colors: '321,123',
            shipping_address:
            {
              company: 'company',
              firstname: 'test_firstname',
              lastname: 'test_lastname',
              address1: 'address1',
              address2: 'address2',
              zipcode: '19020',
              phone: '123-456-7890',
              state_id: 1
            },
            shipping_option: :ups_ground
          }
        }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(400)
      expect(json['errors'].any?).to be_truthy
      expect(json['errors'].include?("City can't be blank")).to be_truthy
    end

    it 'must get a best price with quantity' do
      product = FactoryGirl.create(
        :px_product,
        :with_setup_upcharges,
        :with_run_upcharges,
        :with_carton
      )
      shipping_address = FactoryGirl.create(:address)
      post "/api/products/#{product.id}/best_price",
        {
          id: product.id,
          purchase: {
            quantity: 300,
            shipping_address: shipping_address.id,
            shipping_option: :ups_ground
          }
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
      post "/api/products/#{product.id}/best_price",
        {
          id: product.id,
          purchase: {
            shipping_address: shipping_address.id,
            shipping_option: :fixed_price_per_item
          }
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
      post "/api/products/#{product.id}/best_price",
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
      post "/api/products/#{product.id}/best_price",
        {
          id: product.id,
          purchase: {
            quantity: 200,
            shipping_address: shipping_address.id,
            shipping_option: :fixed_price_per_item
          }
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
      post "/api/products/#{product.id}/best_price",
        {
          id: product.id,
          purchase: {
            shipping_address: shipping_address.id,
            shipping_option: :fixed_price_total
          }
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
      post "/api/products/#{product.id}/best_price",
        {
          id: product.id,
          purchase: {
            quantity: 200,
            shipping_address: shipping_address.id,
            shipping_option: :fixed_price_total
          }
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
      post "/api/products/#{product.id}/best_price",
        {
          id: product.id,
          purchase: {
            quantity: 200,
            shipping_address: shipping_address.id,
            shipping_option: :ups_next_day_air
          }
        }, 'X-Spree-Token' => current_api_user.spree_api_key.to_s
      expect(response).to have_http_status(200)
      expect((json['best_price'].to_f - 5673.72).abs).to be < 0.01
      expect(json['delivery_days']).to eq 8
    end
  end
end

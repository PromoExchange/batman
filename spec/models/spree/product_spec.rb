require 'rails_helper'

RSpec.describe Spree::Product, type: :model do
  describe 'associations' do
    it { should belong_to(:supplier) }
    it { should have_many(:imprint_methods) }
    it { should have_many(:preconfigures) }
    it { should have_many(:upcharges) }
    it { should have_many(:color_product) }
    it { should have_one(:carton) }
    it { should belong_to(:original_supplier) }
    it { should have_many(:imprint_methods_products) }
    it { should have_many(:purchase) }
  end

  describe 'methods' do
    it 'should get minimum_quantity' do
      product = FactoryGirl.create(:px_product)
      expect(product.minimum_quantity).to eq 25
    end

    it 'should get maximum_quantity' do
      product = FactoryGirl.create(:px_product)
      expect(product.maximum_quantity).to eq 2500
    end

    it 'should get last price break minimum' do
      product = FactoryGirl.create(:px_product)
      expect(product.last_price_break_minimum).to eq 200
    end

    it 'should start with an active state' do
      a = FactoryGirl.build(:product)
      expect(a.state).to eq 'active'
    end

    it 'should go to loading with an loading event' do
      a = FactoryGirl.build(:product)
      a.loading!
      expect(a.state).to eq 'loading'
    end

    it 'should go to active with an loaded event' do
      a = FactoryGirl.build(:product)
      a.loading!
      a.loaded!
      expect(a.state).to eq 'active'
    end

    it 'should go to deleted state with an deleted event' do
      a = FactoryGirl.build(:product)
      a.deleted!
      expect(a.state).to eq 'deleted'
    end

    it 'should give price code of V' do
      p = FactoryGirl.build(:product)
      expect(p.price_code).to eq 'V'
    end

    it 'should give a eqp price_code', focus: true do
      p = FactoryGirl.create(:px_product, :with_price_codes)
      expect(p.eqp_price_code).to eq 'R'
    end

    it 'should give a eqp price', focus: true do
      p = FactoryGirl.create(:px_product)
      expect(p.eqp_price).to eq 25.99
    end

    it 'should have a valid carton' do
      product = FactoryGirl.create(:px_product)
      expect(product.carton.active?).to be_truthy
    end

    it 'should only have 1 primary configuration' do
      product = FactoryGirl.create(:px_product)
      expect(product.primary_configuration).not_to be_nil
    end

    it 'should have a valid preconfig' do
      product = FactoryGirl.create(:px_product)
      expect(product.primary_configuration.custom_pms_colors).to eq '321'
    end

    it 'should save a valid px_product' do
      product = FactoryGirl.build(:px_product)
      expect(product.save).to be_truthy
    end

    it 'should save a valid px_product with upcharges' do
      product = FactoryGirl.create(:px_product, :with_run_upcharges, :with_setup_upcharges)
      expect(product.save).to be_truthy
      product2 = Spree::Product.find(product.id)
      expect(product2.upcharges.count).to eq 3
    end

    it 'should save a valid px_product with main_colors' do
      product = FactoryGirl.create(:px_product)
      expect(product.save).to be_truthy
      product2 = Spree::Product.find(product.id)
      expect(product2.color_product.count).to eq 5
    end

    it 'should have a valid company store' do
      product = FactoryGirl.create(:px_product)
      expect(product.company_store).not_to be_nil
    end

    it 'should return the first imprint method' do
      product = FactoryGirl.create(:px_product)
      expect(product.imprint_method).to eq(product.imprint_methods.first)
    end

    it 'should have a specific cache key' do
      product = FactoryGirl.create(:px_product)
      expect(product.cache_key =~ /#{product.id}/).to be_truthy
      expect(product.cache_key =~ /^#{product.model_name.cache_key}/).to be_truthy
    end

    it 'should have a specific cache key for new' do
      product = FactoryGirl.build(:px_product)
      expect(product.cache_key =~ /new/).to be_truthy
      expect(product.cache_key =~ /^#{product.model_name.cache_key}/).to be_truthy
    end

    it 'should allow valid shipping methods' do
      product = FactoryGirl.create(:px_product, :with_carton)
      expect(product.valid_shipping_option?(:ups_ground)).to be_truthy
      expect(product.valid_shipping_option?(:ups_3day_select)).to be_truthy
      expect(product.valid_shipping_option?(:ups_second_day_air)).to be_truthy
      expect(product.valid_shipping_option?(:ups_next_day_air_saver)).to be_truthy
      expect(product.valid_shipping_option?(:ups_next_day_air_early_am)).to be_truthy
      expect(product.valid_shipping_option?(:ups_next_day_air)).to be_truthy
      expect(product.valid_shipping_option?(:fixed_price_per_item)).to be_falsey
      expect(product.valid_shipping_option?(:fixed_price_total)).to be_falsey
    end

    it 'should allow valid shipping methods (fixed price - item)' do
      product = FactoryGirl.create(:px_product, :with_fixed_price_per_item_carton)

      expect(product.valid_shipping_option?(:fixed_price_per_item)).to be_truthy

      expect(product.valid_shipping_option?(:fixed_price_total)).to be_falsey
      expect(product.valid_shipping_option?(:ups_ground)).to be_falsey
      expect(product.valid_shipping_option?(:ups_3day_select)).to be_falsey
      expect(product.valid_shipping_option?(:ups_second_day_air)).to be_falsey
      expect(product.valid_shipping_option?(:ups_next_day_air_saver)).to be_falsey
      expect(product.valid_shipping_option?(:ups_next_day_air_early_am)).to be_falsey
      expect(product.valid_shipping_option?(:ups_next_day_air)).to be_falsey
    end

    it 'should allow valid shipping methods (fixed price - total)' do
      product = FactoryGirl.create(:px_product, :with_fixed_price_total_carton)

      expect(product.valid_shipping_option?(:fixed_price_total)).to be_truthy

      expect(product.valid_shipping_option?(:fixed_price_per_item)).to be_falsey
      expect(product.valid_shipping_option?(:ups_ground)).to be_falsey
      expect(product.valid_shipping_option?(:ups_3day_select)).to be_falsey
      expect(product.valid_shipping_option?(:ups_second_day_air)).to be_falsey
      expect(product.valid_shipping_option?(:ups_next_day_air_saver)).to be_falsey
      expect(product.valid_shipping_option?(:ups_next_day_air_early_am)).to be_falsey
      expect(product.valid_shipping_option?(:ups_next_day_air)).to be_falsey
    end

    it 'should return a valid set of shipping options' do
      product = FactoryGirl.create(:px_product, :with_carton)

      valid_shipping_options = product.available_shipping_options

      [
        :ups_ground,
        :ups_3day_select,
        :ups_second_day_air,
        :ups_next_day_air_saver,
        :ups_next_day_air_early_am,
        :ups_next_day_air
      ].each do |shipping_option|
        expect(valid_shipping_options.include?(shipping_option.to_s)).to be_truthy
      end
      expect(valid_shipping_options.exclude?(:fixed_price_per_item.to_s)).to be_truthy
      expect(valid_shipping_options.exclude?(:fixed_price_total.to_s)).to be_truthy
    end

    it 'should return a valid set of shipping options (fixed price - item)' do
      product = FactoryGirl.create(:px_product, :with_fixed_price_per_item_carton)

      valid_shipping_options = product.available_shipping_options

      expect(valid_shipping_options.include?(:fixed_price_per_item.to_s)).to be_truthy

      expect(valid_shipping_options.exclude?(:fixed_price_total.to_s)).to be_truthy
      expect(valid_shipping_options.exclude?(:ups_ground.to_s)).to be_truthy
      expect(valid_shipping_options.exclude?(:ups_3day_select.to_s)).to be_truthy
      expect(valid_shipping_options.exclude?(:ups_second_day_air.to_s)).to be_truthy
      expect(valid_shipping_options.exclude?(:ups_next_day_air_saver.to_s)).to be_truthy
      expect(valid_shipping_options.exclude?(:ups_next_day_air_early_am.to_s)).to be_truthy
      expect(valid_shipping_options.exclude?(:ups_next_day_air.to_s)).to be_truthy
    end

    it 'should return a valid set of shipping options (fixed price - total)' do
      product = FactoryGirl.create(:px_product, :with_fixed_price_total_carton)

      valid_shipping_options = product.available_shipping_options

      expect(valid_shipping_options.include?(:fixed_price_total.to_s)).to be_truthy
      expect(valid_shipping_options.exclude?(:fixed_price_per_item.to_s)).to be_truthy
      expect(valid_shipping_options.exclude?(:ups_ground.to_s)).to be_truthy
      expect(valid_shipping_options.exclude?(:ups_3day_select.to_s)).to be_truthy
      expect(valid_shipping_options.exclude?(:ups_second_day_air.to_s)).to be_truthy
      expect(valid_shipping_options.exclude?(:ups_next_day_air_saver.to_s)).to be_truthy
      expect(valid_shipping_options.exclude?(:ups_next_day_air_early_am.to_s)).to be_truthy
      expect(valid_shipping_options.exclude?(:ups_next_day_air.to_s)).to be_truthy
    end
  end
end

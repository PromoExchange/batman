require 'rails_helper'

RSpec.describe Spree::Product, type: :model do
  describe 'associations' do
    it { should belong_to(:supplier) }
    it { should have_many(:imprint_methods) }
    it { should have_one(:preconfigure) }
    it { should have_many(:upcharges) }
    it { should have_many(:color_product) }
    it { should have_one(:carton) }
    it { should belong_to(:original_supplier) }
    it { should have_many(:imprint_methods_products) }
    it { should have_many(:purchase) }
  end

  describe 'methods' do
    xit 'should get a best price' do
      product = FactoryGirl.create(
        :px_product,
        :with_setup_upcharges,
        :with_run_upcharges,
        :with_carton
      )
      shipping_address = FactoryGirl.create(:address)
      best_price = product.best_price(
        shipping_address: shipping_address.id,
        shipping_option: Spree::ShippingOption::OPTION[:ups_ground]
      )
      expect(best_price[:best_price].to_f).to eq 675.37
      expect(best_price[:delivery_days]).to eq 12
    end
  end

  it 'should get minimum_quantity', focus: true do
    product = FactoryGirl.create(:px_product)
    expect(product.minimum_quantity).to eq 25
  end

  it 'should get maximum_quantity', focus: true do
    product = FactoryGirl.create(:px_product)
    expect(product.maximum_quantity).to eq 2500
  end

  it 'should get last price break minimum', focus: true do
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

  it 'should have a valid carton' do
    product = FactoryGirl.create(:px_product)
    expect(product.carton.active?).to be_truthy
  end

  it 'should have a valid preconfig' do
    product = FactoryGirl.create(:px_product)
    expect(product.preconfigure.custom_pms_colors).to eq '321'
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
end

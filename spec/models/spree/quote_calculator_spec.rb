require 'rails_helper'

RSpec.describe Spree::Quote, type: :model do
  let(:quote) { FactoryGirl.create(:quote) }

  it 'should apply price discount' do
    discount = 0.50
    ('A'..'K').each do |letter|
      quote.unit_price = 100
      quote.apply_price_discount(letter)
      expect(((discount * 100) - quote.unit_price).abs).to be < 0.0001
      discount += 0.05
    end
  end

  it 'should apply EQP discount' do
    quote = FactoryGirl.create(:quote, product: FactoryGirl.create(:px_product, :with_eqp))
    quote.apply_eqp
    expect((quote.unit_price - 16.6336).abs).to be < 0.0001
  end

  it 'should not apply no_eqp_range' do
    quote = FactoryGirl.create(:quote, product: FactoryGirl.create(:px_product,
      :with_eqp,
      :with_no_eqp_range))
    quote.apply_eqp
    expect((quote.unit_price - 29.99).abs).to be < 0.0001
  end

  it 'should apply pricing discount' do
    quote = FactoryGirl.create(:quote)
    quote.unit_price = quote.product.unit_price(quote.quantity)
    quote.apply_price_discount
    expect((quote.unit_price - 23.992).abs).to be < 0.001
  end

  it 'should apply seller markup' do
    quote = FactoryGirl.create(:quote)
    quote.unit_price = quote.product.unit_price(quote.quantity)
    quote.apply_seller_markup
    expect((quote.unit_price - 32.989).abs).to be < 0.001
  end

  it 'should apply PX commission' do
    quote = FactoryGirl.create(:quote)
    quote.unit_price = quote.product.unit_price(quote.quantity)
    quote.apply_px_commission
    expect((quote.unit_price - 32.9524).abs).to be < 0.001
  end

  it 'should apply processing fee' do
    quote = FactoryGirl.create(:quote)
    quote.unit_price = quote.product.unit_price(quote.quantity)
    quote.apply_processing_fee
    expect((quote.unit_price - 30.897).abs).to be < 0.001
  end

  xit 'should calculate quote with 25 quantity' do
    quote = FactoryGirl.create(:quote)
    expect((quote.total_price - 767.331).abs).to be < 0.001
  end

  xit 'should calculate quote with 125 quantity' do
    quote = FactoryGirl.create(:quote, quantity: 125)
    expect((quote.total_price - 3504.799).abs).to be < 0.001
  end

  xit 'should calculate quote with 225 quantity' do
    quote = FactoryGirl.create(:quote, quantity: 225)
    expect((quote.total_price - 5864.371).abs).to be < 0.001
  end

  xit 'should apply product less_than_minimum charge' do
    quote2 = FactoryGirl.create(:quote, :with_less_than_minimum)
    expect((quote2.total_price(quantity: 75) - 842.016).abs).to be < 0.001
    expect(quote2.total_price).to be > quote.total_price
  end

  xit 'should apply product setup charge' do
    quote2 = FactoryGirl.create(:quote, :with_setup_upcharges)
    expect((quote2.total_price - 1016.282).abs).to be < 0.001
    expect(quote2.total_price).to be > quote.total_price
  end

  xit 'should apply product run charges' do
    quote2 = FactoryGirl.create(:quote, :with_run_upcharges)
    expect((quote2.total_price - 778.783).abs).to be < 0.001
    expect(quote2.total_price).to be > quote.total_price
  end

  xit 'should apply product setup and run charges' do
    quote2 = FactoryGirl.create(:quote, :with_setup_and_run_upcharges)
    expect((quote2.total_price - 1027.734).abs).to be < 0.001
    expect(quote2.total_price).to be > quote.total_price
  end

  xit 'should apply product setup and run charges with quantity' do
    quote2 = FactoryGirl.create(:quote, :with_setup_and_run_upcharges)
    quote2.quantity = 125
    expect((quote2.total_price - 3811.009).abs).to be < 0.001
    expect(quote2.total_price).to be > quote.total_price
  end

  xit 'should apply additional location charge' do
    quote2 = FactoryGirl.create(:quote, :with_additional_location_upcharge)
    quote2.num_locations = 2
    expect((quote2.total_price - 769.820).abs).to be < 0.001
    expect(quote2.total_price).to be > quote.total_price
  end

  xit 'should apply additional location charge with quantity' do
    quote = FactoryGirl.create(:quote, quantity: 125)
    quote2 = FactoryGirl.create(:quote, :with_additional_location_upcharge, quantity: 125)
    quote2.num_locations = 2
    expect((quote2.total_price - 3514.757).abs).to be < 0.001
    expect(quote2.total_price).to be > quote.total_price
  end

  xit 'should provide fixed shipping per item' do
    quote = FactoryGirl.create(:quote, :with_fixed_price_per_item)
    expect((quote.total_price - 824.702).abs).to be < 0.001
  end

  xit 'should provide fixed shipping total' do
    quote = FactoryGirl.create(:quote, :with_fixed_price_total)
    expect((quote.total_price - 871.380).abs).to be < 0.001
  end

  # TODO: Mock UPS calls!
  xit 'should use non fixed shipping' do
    quote = FactoryGirl.create(:quote, :with_carton)
    expect((quote.total_price - 767.331).abs).to be < 0.001
  end

  xit 'should use non fixed shipping 3day' do
    quote = FactoryGirl.create(:quote, :with_carton)
    expect((quote.total_price(shipping_option: :ups_3day_select) - 794.442).abs).to be < 0.001
  end

  xit 'should use carton upcharge' do
    quote = FactoryGirl.create(:quote, :with_carton_upcharge)
    expect((quote.total_price - 781.110).abs).to be < 0.001
  end

  xit 'should use carton upcharge with multiple cartons' do
    quote = FactoryGirl.create(:quote, :with_carton_upcharge, quantity: 250)
    expect((quote.total_price - 6538.955).abs).to be < 0.001
  end

  xit 'should use higher cost for express shipping' do
    quote = FactoryGirl.create(:quote, :with_carton)
    standard_price = quote.total_price(shipping_option: :ups_ground)
    express_price = quote.total_price(shipping_option: :ups_next_day_air)
    expect(express_price).to be > standard_price
  end

  xit 'should return selected shipping option' do
    quote = FactoryGirl.create(:quote, :with_carton)
    quote.total_price(shipping_option: :ups_ground)
    expect(quote.shipping.shipping_option).to eq Spree::ShippingOption::OPTION[:ups_ground]
  end
end

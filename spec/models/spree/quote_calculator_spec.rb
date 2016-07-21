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

  it 'should apply pricing discount' do
    quote = FactoryGirl.create(:quote)
    quote.unit_price = quote.product.unit_price(quote.quantity)
    quote.apply_price_discount
    expect((quote.unit_price - 23.992).abs).to be < 0.001
  end

  xit 'should calculate quote with 25 quantity' do
    quote = FactoryGirl.create(:quote)
    expect((quote.total_price - 616.17).abs).to be < 0.001
  end

  xit 'should calculate quote with 125 quantity' do
    quote = FactoryGirl.create(:quote, quantity: 125)
    expect((quote.total_price - 2815.37).abs).to be < 0.001
  end

  xit 'should calculate quote with 225 quantity' do
    quote = FactoryGirl.create(:quote, quantity: 225)
    expect((quote.total_price - 4710.94).abs).to be < 0.001
  end

  xit 'should apply product setup charge' do
    quote2 = FactoryGirl.create(:quote, :with_setup_upcharges)
    expect((quote2.total_price - 816.17).abs).to be < 0.001
    expect(quote2.total_price).to be > quote.total_price
  end

  xit 'should apply product run charges' do
    quote2 = FactoryGirl.create(:quote, :with_run_upcharges)
    expect((quote2.total_price - 625.37).abs).to be < 0.001
    expect(quote2.total_price).to be > quote.total_price
  end

  xit 'should apply product setup and run charges' do
    quote2 = FactoryGirl.create(:quote, :with_setup_and_run_upcharges)
    expect((quote2.total_price - 825.37).abs).to be < 0.001
    expect(quote2.total_price).to be > quote.total_price
  end

  xit 'should apply additional location charge' do
    quote2 = FactoryGirl.create(:quote, :with_additional_location_upcharge)
    quote2.num_locations = 2
    expect((quote2.total_price - 618.17).abs).to be < 0.001
    expect(quote2.total_price).to be > quote.total_price
  end

  xit 'should apply additional location charge with quantity' do
    quote = FactoryGirl.create(:quote, quantity: 125)
    quote2 = FactoryGirl.create(:quote, :with_additional_location_upcharge, quantity: 125)
    quote2.num_locations = 2
    expect((quote2.total_price - 2823.37).abs).to be < 0.001
    expect(quote2.total_price).to be > quote.total_price
  end

  xit 'should apply second color charge' do
    pending('Implemented in QuoteCalculatorUpcharges but not tested (no requirement)')
  end

  xit 'should apply additional color run charge' do
    pending('Implemented in QuoteCalculatorUpcharges but not tested (no requirement)')
  end

  xit 'should apply additional color run charge' do
    pending('Implemented in QuoteCalculatorUpcharges but not tested (no requirement)')
  end

  it 'should provide fixed shipping per item' do
    quote = FactoryGirl.create(:quote, :with_fixed_price_per_item)
    expect((quote.total_price - 662.3).abs).to be < 0.001
  end

  it 'should provide fixed shipping total' do
    quote = FactoryGirl.create(:quote, :with_fixed_price_total)
    expect((quote.total_price - 699.8).abs).to be < 0.001
  end

  # TODO: Mock UPS calls!
  xit 'should use non fixed shipping' do
    quote = FactoryGirl.create(:quote, :with_carton)
    expect((quote.total_price - 616.17).abs).to be < 0.001
  end

  xit 'should use non fixed shipping 3day' do
    quote = FactoryGirl.create(:quote, :with_carton)
    expect((quote.total_price(selected_shipping_option: :ups_3day_select) - 637.81).abs).to be < 0.001
  end

  xit 'should use higher cost for express shipping' do
    quote = FactoryGirl.create(:quote, :with_carton)
    standard_price = quote.total_price(selected_shipping_option: :ups_ground)
    express_price = quote.total_price(selected_shipping_option: :ups_next_day_air)
    expect(express_price).to be > standard_price
  end

  it 'should return selected shipping option' do
    quote = FactoryGirl.create(:quote, :with_carton)
    quote.total_price(selected_shipping_option: :ups_ground)
    expect(quote.selected_shipping.shipping_option).to eq Spree::ShippingOption::OPTION[:ups_ground]
  end
end

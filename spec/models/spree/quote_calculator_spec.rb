require 'rails_helper'

RSpec.describe Spree::Quote, type: :model do
  let(:quote) { FactoryGirl.create(:quote) }

  it 'should apply price discount' do
    discount = 0.50
    ('A'..'K').each do |letter|
      quote.unit_price = 100
      quote.apply_price_discount(letter)
      expect(((discount * 100) - quote.unit_price).abs).to be < 0.01
      discount += 0.05
    end
  end

  it 'should apply EQP discount' do
    quote = FactoryGirl.create(:quote, product: FactoryGirl.create(:px_product, :with_eqp))
    quote.apply_eqp
    expect((quote.unit_price - 16.63).abs).to be < 0.01
  end

  it 'should not apply no_eqp_range' do
    quote = FactoryGirl.create(:quote, product: FactoryGirl.create(:px_product,
      :with_eqp,
      :with_no_eqp_range))
    quote.apply_eqp
    expect((quote.unit_price - 29.99).abs).to be < 0.01
  end

  it 'should apply pricing discount' do
    quote = FactoryGirl.create(:quote)
    quote.unit_price = quote.product.unit_price(quote.quantity)
    quote.apply_price_discount
    expect((quote.unit_price - 23.99).abs).to be < 0.01
  end

  it 'should apply seller markup' do
    quote = FactoryGirl.create(:quote)
    quote.unit_price = quote.product.unit_price(quote.quantity)
    quote.apply_seller_markup
    expect((quote.unit_price - 32.98).abs).to be < 0.01
  end

  it 'should apply PX commission' do
    quote = FactoryGirl.create(:quote)
    quote.unit_price = quote.product.unit_price(quote.quantity)
    quote.apply_px_commission
    expect((quote.unit_price - 32.95).abs).to be < 0.01
  end

  it 'should apply processing fee' do
    quote = FactoryGirl.create(:quote)
    quote.unit_price = quote.product.unit_price(quote.quantity)
    quote.apply_processing_fee
    expect((quote.unit_price - 30.89).abs).to be < 0.01
  end

  describe '(Can only run locally)', need_ups: true do
    it 'should calculate quote with 25 quantity' do
      quote = FactoryGirl.create(:quote, quantity: 25)
      expect((quote.total_price - 767.33).abs).to be < 0.01
    end

    it 'should calculate quote with 125 quantity' do
      quote = FactoryGirl.create(:quote, quantity: 125)
      expect((quote.total_price - 3504.79).abs).to be < 0.01
    end

    it 'should calculate quote with 225 quantity' do
      quote = FactoryGirl.create(:quote, quantity: 225)
      expect((quote.total_price - 5864.37).abs).to be < 0.01
    end

    it 'should apply product less_than_minimum charge' do
      quote2 = FactoryGirl.create(:quote, :with_less_than_minimum)
      expect((quote2.total_price(quantity: 75) - 842.01).abs).to be < 0.01
      expect(quote2.total_price).to be > quote.total_price
    end

    it 'should apply product setup charge' do
      quote2 = FactoryGirl.create(:quote, :with_setup_upcharges)
      expect((quote2.total_price - 1016.28).abs).to be < 0.01
      expect(quote2.total_price).to be > quote.total_price
    end

    it 'should apply product setup charge twice' do
      quote2 = FactoryGirl.create(:quote, :with_two_setup_upcharges)
      expect((quote2.total_price - 1066.28).abs).to be < 0.01
      expect(quote2.total_price).to be > quote.total_price
    end

    it 'should apply product run charges' do
      quote2 = FactoryGirl.create(:quote, :with_run_upcharges)
      expect((quote2.total_price - 778.78).abs).to be < 0.01
      expect(quote2.total_price).to be > quote.total_price
    end

    it 'should apply product setup and run charges' do
      quote2 = FactoryGirl.create(:quote, :with_setup_and_run_upcharges)
      expect((quote2.total_price - 1027.73).abs).to be < 0.01
      expect(quote2.total_price).to be > quote.total_price
    end

    it 'should apply product setup and run charges with quantity' do
      quote2 = FactoryGirl.create(:quote, :with_setup_and_run_upcharges)
      quote2.quantity = 125
      expect((quote2.total_price - 3811.00).abs).to be < 0.01
      expect(quote2.total_price).to be > quote.total_price
    end

    it 'should apply additional location charge' do
      quote2 = FactoryGirl.create(:quote, :with_additional_location_upcharge)
      quote2.num_locations = 2
      expect((quote2.total_price - 769.82).abs).to be < 0.01
      expect(quote2.total_price).to be > quote.total_price
    end

    it 'should apply additional location charge with quantity' do
      quote = FactoryGirl.create(:quote, quantity: 125)
      quote2 = FactoryGirl.create(:quote, :with_additional_location_upcharge, quantity: 125)
      quote2.num_locations = 2
      expect((quote2.total_price - 3514.75).abs).to be < 0.01
      expect(quote2.total_price).to be > quote.total_price
    end

    it 'should provide fixed shipping per item' do
      quote = FactoryGirl.create(:quote, :with_fixed_price_per_item)
      expect((quote.total_price - 824.70).abs).to be < 0.01
    end

    it 'should provide fixed shipping total' do
      quote = FactoryGirl.create(:quote, :with_fixed_price_total)
      expect((quote.total_price - 871.38).abs).to be < 0.01
    end

    # TODO: Mock UPS calls!
    it 'should use non fixed shipping' do
      quote = FactoryGirl.create(:quote, :with_carton)
      expect((quote.total_price - 767.33).abs).to be < 0.01
    end

    it 'should use non fixed shipping 3day' do
      quote = FactoryGirl.create(:quote, :with_carton)
      expect((quote.total_price(shipping_option: :ups_3day_select) - 794.56).abs).to be < 0.01
    end

    it 'should use carton upcharge' do
      quote = FactoryGirl.create(:quote, :with_carton_upcharge)
      expect((quote.total_price - 781.16).abs).to be < 0.01
    end

    it 'should use carton upcharge with multiple cartons' do
      quote = FactoryGirl.create(:quote, :with_carton_upcharge, quantity: 250)
      expect((quote.total_price - 6539.05).abs).to be < 0.01
    end

    it 'should use higher cost for express shipping' do
      quote = FactoryGirl.create(:quote, :with_carton)
      standard_price = quote.total_price(shipping_option: :ups_ground)
      express_price = quote.total_price(shipping_option: :ups_next_day_air)
      expect(express_price).to be > standard_price
    end
  end
end

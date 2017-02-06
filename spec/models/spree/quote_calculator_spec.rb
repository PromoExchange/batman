require 'rails_helper'

RSpec.describe Spree::Quote, type: :model do
  let(:quote) { FactoryGirl.create(:quote) }

  describe '(Can only run locally)', need_ups: true do
    it 'should calculate quote with 25 quantity' do
      quote = FactoryGirl.create(:quote, quantity: 25)
      expect((quote.price[:total_price] - 768.43).abs).to be < 0.01
    end

    it 'should calculate quote with 125 quantity' do
      quote = FactoryGirl.create(:quote, quantity: 125)
      expect((quote.price[:total_price] - 3505.90).abs).to be < 0.01
    end

    it 'should calculate quote with 225 quantity' do
      quote = FactoryGirl.create(:quote, quantity: 225)
      expect((quote.price[:total_price] - 5866.58).abs).to be < 0.01
    end

    it 'should apply product less_than_minimum charge' do
      quote2 = FactoryGirl.create(:quote, :with_less_than_minimum)
      expect((quote2.price[:total_price] - 843.12).abs).to be < 0.01
      expect(quote2.price[:total_price]).to be > quote.price[:total_price]
    end

    it 'should apply product setup charge', focus: true do
      quote = FactoryGirl.create(:quote, :with_setup_upcharges)
      expect((quote.price[:total_price] - 1017.39).abs).to be < 0.01
    end

    it 'should apply product setup charge twice', focus: true do
      quote2 = FactoryGirl.create(:quote, :with_two_setup_upcharges)
      expect((quote2.price[:total_price] - 1266.34).abs).to be < 0.01
    end

    it 'should apply product setup with ranges', focus: true do
      quote2 = FactoryGirl.create(:quote, :with_range_setup_upcharges)
      expect((quote2.price[:total_price] - 1515.29).abs).to be < 0.01
    end

    it 'should apply product run charges' do
      quote2 = FactoryGirl.create(:quote, :with_run_upcharges)
      expect((quote2.price[:total_price] - 779.89).abs).to be < 0.01
      expect(quote2.price[:total_price]).to be > quote.price[:total_price]
    end

    it 'should apply product setup and run charges' do
      quote2 = FactoryGirl.create(:quote, :with_setup_and_run_upcharges)
      expect((quote2.price[:total_price] - 1028.84).abs).to be < 0.01
      expect(quote2.price[:total_price]).to be > quote.price[:total_price]
    end

    it 'should apply product setup and run charges with quantity' do
      quote2 = FactoryGirl.create(:quote, :with_setup_and_run_upcharges, quantity: 125)
      expect((quote2.price[:total_price] - 3812.11).abs).to be < 0.01
      expect(quote2.price[:total_price]).to be > quote.price[:total_price]
    end

    it 'should apply additional location charge' do
      quote2 = FactoryGirl.create(:quote, :with_additional_location_upcharge, num_locations: 2)
      expect((quote2.price[:total_price] - 770.92).abs).to be < 0.01
      expect(quote2.price[:total_price]).to be > quote.price[:total_price]
    end

    it 'should apply additional location charge with quantity' do
      quote = FactoryGirl.create(:quote, quantity: 125)
      quote2 = FactoryGirl.create(:quote, :with_additional_location_upcharge, quantity: 125, num_locations: 2)
      expect((quote2.price[:total_price] - 3515.86).abs).to be < 0.01
      expect(quote2.price[:total_price]).to be > quote.price[:total_price]
    end

    it 'should provide fixed shipping per item' do
      quote = FactoryGirl.create(:quote, :with_fixed_price_per_item)
      expect((quote.price[:total_price] - 824.70).abs).to be < 0.01
    end

    it 'should provide fixed shipping total' do
      quote = FactoryGirl.create(:quote, :with_fixed_price_total)
      expect((quote.price[:total_price] - 871.38).abs).to be < 0.01
    end

    it 'should use non fixed shipping' do
      quote = FactoryGirl.create(:quote, :with_carton)
      expect((quote.price[:total_price] - 768.43).abs).to be < 0.01
    end

    it 'should use non fixed shipping 3day' do
      quote = FactoryGirl.create(:quote, :with_carton, shipping_option: :ups_3day_select)
      expect((quote.price[:total_price] - 797.24).abs).to be < 0.01
    end

    it 'should use carton upcharge' do
      quote = FactoryGirl.create(:quote, :with_carton_upcharge)
      expect((quote.price[:total_price] - 782.26).abs).to be < 0.01
    end

    it 'should use carton upcharge with multiple cartons' do
      quote = FactoryGirl.create(:quote, :with_carton_upcharge, quantity: 250)
      expect((quote.price[:total_price] - 6541.27).abs).to be < 0.01
    end

    it 'should use higher cost for express shipping' do
      quote = FactoryGirl.create(:quote, :with_carton, shipping_option: :ups_ground)
      quote2 = FactoryGirl.create(:quote, :with_carton, shipping_option: :ups_next_day_air)
      standard_price = quote.price[:total_price]
      express_price = quote2.price[:total_price]
      expect(express_price).to be > standard_price
    end
  end
end

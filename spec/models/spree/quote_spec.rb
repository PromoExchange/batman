require 'rails_helper'

describe Spree::Quote, type: :model do
  describe 'factory' do
    it 'should build with a valid quote' do
      quote = FactoryGirl.build(:quote)
      expect(quote.valid?).to be_truthy
    end

    it 'should build a valid quote with_setup_upcharges' do
      quote = FactoryGirl.build(:quote, :with_setup_upcharges)
      expect(quote.valid?).to be_truthy
    end

    it 'should build a valid quote with_run_upcharges' do
      quote = FactoryGirl.build(:quote, :with_run_upcharges)
      expect(quote.valid?).to be_truthy
    end

    it 'should build a valid quote with_setup_and_run_upcharges' do
      quote = FactoryGirl.build(:quote, :with_setup_and_run_upcharges)
      expect(quote.valid?).to be_truthy
    end

    it 'should build a valid quote with_additional_location_upcharge' do
      quote = FactoryGirl.build(:quote, :with_additional_location_upcharge)
      expect(quote.valid?).to be_truthy
    end

    it 'should build a valid quote with_fixed_price_per_item' do
      quote = FactoryGirl.build(:quote, :with_fixed_price_per_item)
      expect(quote.valid?).to be_truthy
    end

    it 'should build a valid quote with_fixed_price_total' do
      quote = FactoryGirl.build(:quote, :with_fixed_price_total)
      expect(quote.valid?).to be_truthy
    end

    it 'should build a valid quote with_carton' do
      quote = FactoryGirl.build(:quote, :with_carton)
      expect(quote.valid?).to be_truthy
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:main_color) }
    it { should validate_presence_of(:shipping_address) }
    it { should validate_presence_of(:shipping_option) }
  end

  describe 'associations' do
    it { should belong_to(:main_color) }
    it { should belong_to(:product) }
    it { should belong_to(:shipping_address) }
    it { should have_many(:pms_colors) }
  end

  describe 'methods' do
    it 'should return num of colors' do
      quote = FactoryGirl.create(:quote)
      expect(quote.num_colors).to eq 4
    end

    it 'should return shipping option name (UPS Ground)' do
      quote = FactoryGirl.create(:quote)
      expect(quote.shipping_option_name).to eq('UPS Ground')
    end

    it 'should return shipping option name (UPS 3day Select)' do
      quote = FactoryGirl.create(:quote, :with_3day_select)
      expect(quote.shipping_option_name).to eq('UPS 3day Select')
    end

    it 'should return shipping option name (Fixed Price per item)' do
      quote = FactoryGirl.create(:quote, :with_fixed_price_per_item)
      expect(quote.shipping_option_name).to eq('Fixed Price')
    end

    it 'should return shipping option name (Fixed Price total)' do
      quote = FactoryGirl.create(:quote, :with_fixed_price_total)
      expect(quote.shipping_option_name).to eq('Fixed Price')
    end

    it 'should have a default shipping days of 5 (Fixed Price)' do
      quote = FactoryGirl.create(:quote, :with_fixed_price_total)
      expect(quote.price[:shipping_days]).to eq(5)
    end

    it 'should generate a reference' do
      quote = FactoryGirl.create(:quote, reference: nil)
      quote2 = Spree::Quote.find(quote.id)
      expect(quote2.reference).not_to be_empty
    end
  end
end

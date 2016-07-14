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
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:selected_shipping_option) }
    it { should_not allow_value(1).for(:quantity) }
    it { should allow_value(50).for(:quantity) }
    it { should validate_numericality_of(:quantity).only_integer }
  end

  describe 'associations' do
    it { should belong_to(:main_color) }
    it { should belong_to(:product) }
    it { should belong_to(:shipping_address) }
    it { should have_many(:shipping_options) }
    it { should have_many(:pms_colors) }

    it 'should delete shipping_options' do
      quote_with_shipping = FactoryGirl.create(:quote)
      expect { quote_with_shipping.destroy }.to change { Spree::ShippingOption.count }.by(-5)
    end
  end

  describe 'messages' do
    it 'should add a log message' do
      quote = FactoryGirl.build(:quote)
      5.times { quote.log('Test message') }
      expect(quote.messages.count).to eq 5
    end

    it 'should save and restore messages' do
      quote = FactoryGirl.build(:quote)
      5.times { quote.log('Test message') }
      quote.save
      quote2 = Spree::Quote.find(quote.id)
      expect(quote2.messages.count).to eq 5
    end

    it 'should clear messages' do
      quote = FactoryGirl.create(:quote)
      5.times { quote.log('Test Message') }
      expect(quote.messages.count).to eq 5
      quote.clear_log
      expect(quote.messages.count).to eq 0
    end
  end

  describe 'methods' do
    it 'should return num of colors' do
      quote = FactoryGirl.create(:quote)
      expect(quote.num_colors).to eq 4
    end

    it 'should generate a reference' do
      quote = FactoryGirl.create(:quote, reference: nil)
      quote2 = Spree::Quote.find(quote.id)
      expect(quote2.reference).not_to be_empty
    end

    it 'should have a specific cache key' do
      quote = FactoryGirl.create(:quote)
      expect(quote.cache_key =~ /#{quote.product.id}/).to be_truthy
      expect(quote.cache_key =~ /#{quote.quantity}/).to be_truthy
      expect(quote.cache_key =~ /#{quote.selected_shipping_option}/).to be_truthy
      expect(quote.cache_key =~ /#{quote.model_name.cache_key}/).to be_truthy
    end

    it 'should have a specific cache key with shipping option' do
      quote = FactoryGirl.create(:quote)
      expect(quote.cache_key(5) =~ /#{quote.product.id}/).to be_truthy
      expect(quote.cache_key(5) =~ /#{quote.quantity}/).to be_truthy
      expect(quote.cache_key(5) =~ /#{5}/).to be_truthy
      expect(quote.cache_key(5) =~ /#{quote.model_name.cache_key}/).to be_truthy
    end
  end
end

require 'rails_helper'

# Skipped (by file name) pending reorganize
RSpec.describe Spree::ShippingOption, type: :model do
  describe 'factory' do
    it 'should build a valid shipping_option (default)' do
      shipping_option = FactoryGirl.build(:shipping_option)
      expect(shipping_option.valid?).to be_truthy
    end

    it 'should build a valid shipping_option (3day)' do
      shipping_option = FactoryGirl.build(:shipping_option, :ups_3day_select)
      expect(shipping_option.valid?).to be_truthy
    end

    it 'should build a valid shipping_option (fixed_price)' do
      shipping_option = FactoryGirl.build(:shipping_option, :fixed_price_per_item)
      expect(shipping_option.valid?).to be_truthy
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:delivery_date) }
    it { should validate_presence_of(:delivery_days) }
    it { should validate_presence_of(:shipping_option) }
    it { should validate_presence_of(:shipping_cost) }
    it { should validate_presence_of(:quote_id) }
    it { should validate_inclusion_of(:shipping_option).in_array(Spree::ShippingOption::OPTION.values) }
  end

  describe 'association' do
    it { should belong_to(:quote) }
  end
end

require 'rails_helper'

# Skipped (by file name) pending reorganize
RSpec.describe Spree::ShippingOption, type: :model do
  describe 'factory' do
    it 'should build a valid shipping_option' do
      shipping_option = FactoryGirl.build(:shipping_option)
      expect(shipping_option.valid?).to be_truthy
    end
  end

  describe 'association' do
    it { should belong_to(:quote) }
  end
end

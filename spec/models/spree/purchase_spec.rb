require 'rails_helper'

RSpec.describe Spree::Purchase, type: :model do
  describe 'factory' do
    it 'should build a valid purchase' do
      purchase = FactoryGirl.build(:purchase)
      expect(purchase.valid?).to be_truthy
    end

    it 'should build a valid purchase with sizes' do
      purchase = FactoryGirl.build(:purchase, :with_sizes)
      expect(purchase.valid?).to be_truthy
    end
  end
end

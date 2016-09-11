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

  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:product_id) }
    it { should validate_presence_of(:logo_id) }
    it { should validate_presence_of(:imprint_method_id) }
    it { should validate_presence_of(:main_color_id) }
    it { should validate_presence_of(:buyer_id) }
    it { should validate_presence_of(:shipping_option) }
  end

  describe 'methods' do
    it 'should return an array of sizes' do
      expect(Spree::Purchase.sizes.is_a?(Array)).to be_truthy
      expect(Spree::Purchase.sizes.length).to eq 5
    end
  end

  describe 'associations' do
    it { should belong_to(:order) }
  end
end

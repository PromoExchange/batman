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
    it { should validate_presence_of(:address_id) }
  end

  describe 'methods' do
    it 'should return an array of sizes' do
      expect(Spree::Purchase.sizes.is_a?(Array)).to be_truthy
      expect(Spree::Purchase.sizes.length).to eq 5
    end

    it 'should generate a reference' do
      purchase = FactoryGirl.create(:purchase)
      purchase2 = Spree::Purchase.find(purchase.id)
      expect(purchase2.reference).not_to be_empty
    end

    xit 'should destroy dependent order' do
      # TODO: Need factories to complete purchase
      purchase = FactoryGirl.create(:purchase)
      expect { purchase.destroy }.to change { Spree::Order.count }.by(-1)
    end

    # TODO: Need tests for accept and invoice emails
  end

  describe 'associations' do
    it { should belong_to(:order) }
    it { should belong_to(:product) }
    it { should belong_to(:logo) }
    it { should belong_to(:imprint_method) }
    it { should belong_to(:main_color) }
    it { should belong_to(:buyer) }
    it { should belong_to(:address) }
    it { should belong_to(:order) }
  end
end

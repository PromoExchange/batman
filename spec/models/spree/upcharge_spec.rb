require 'rails_helper'

RSpec.describe Spree::UpchargeProduct, type: :model do
  describe 'factory' do
    xit 'should build a valid upcharge :supplier_upcharge' do
      upcharge = FactoryGirl.build(:supplier_upcharge)
      expect(upcharge.valid?).to be_truthy
    end

    xit 'should build a valid upcharge :product_run_upcharge' do
      upcharge = FactoryGirl.build(:product_run_upcharge)
      expect(upcharge.valid?).to be_truthy
    end

    xit 'should build a valid upcharge :product_setup_upcharge' do
      upcharge = FactoryGirl.build(:product_setup_upcharge)
      expect(upcharge.valid?).to be_truthy
    end

    xit 'should build a valid upcharge :product_additional_location_upcharge' do
      upcharge = FactoryGirl.build(:product_additional_location_upcharge)
      expect(upcharge.valid?).to be_truthy
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:upcharge_type_id) }
    it { should validate_presence_of(:type) }
    it { should validate_presence_of(:related_id) }
    it { should validate_presence_of(:value) }
  end

  describe 'associations' do
    it { should belong_to(:product) }
    it { should belong_to(:imprint_method) }
  end
end

require 'rails_helper'

RSpec.describe Spree::Preconfigure, type: :model do
  describe 'factory' do
    it 'should create a valid preconfigure' do
      preconfigure = FactoryGirl.build(:preconfigure)
      expect(preconfigure.valid?).to be_truthy
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:product_id) }
    it { should validate_presence_of(:buyer_id) }
    it { should validate_presence_of(:imprint_method_id) }
    it { should validate_presence_of(:main_color_id) }
    it { should validate_presence_of(:logo_id) }
    it { should validate_presence_of(:primary) }
  end

  describe 'associations' do
    it { should belong_to(:product) }
    it { should belong_to(:buyer) }
    it { should belong_to(:imprint_method) }
    it { should belong_to(:main_color) }
    it { should belong_to(:logo) }
  end
end

require 'rails_helper'

RSpec.describe Spree::Markup, type: :model do
  describe 'factory' do
    it 'should build a valid markup' do
      markup = FactoryGirl.build(:markup)
      expect(markup.valid?).to be_truthy
    end

    it 'should build a valid markup with eqp' do
      markup = FactoryGirl.build(:markup, :eqp_discount)
      expect(markup.valid?).to be_truthy
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:supplier_id) }
    it { should validate_presence_of(:markup) }
    it { should validate_presence_of(:company_store_id) }
  end

  describe 'associations' do
    it { should belong_to(:supplier) }
    it { should belong_to(:company_store) }
  end

  describe 'methods' do
    it 'should return true for eqp?' do
      markup = FactoryGirl.build(:markup)
      expect(markup.eqp?).to be_falsey
    end

    it 'should return true for eqp?' do
      markup = FactoryGirl.build(:markup, :eqp_discount)
      expect(markup.eqp?).to be_truthy
    end
  end
end

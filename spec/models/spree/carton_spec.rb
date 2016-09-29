require 'rails_helper'

RSpec.describe Spree::Carton, type: :model do
  describe 'factory' do
    it 'should build a valid carton' do
      carton = FactoryGirl.build(:carton)
      expect(carton.valid?).to be_truthy
    end

    it 'should build a valid fixed_price per item carton' do
      carton = FactoryGirl.build(:carton, :with_fixed_price_per_item)
      expect(carton.valid?).to be_truthy
    end

    it 'should build a valid fixed_price total carton' do
      carton = FactoryGirl.build(:carton, :with_fixed_price_total)
      expect(carton.valid?).to be_truthy
    end

    it 'should build a valid fixed_price with upcharge' do
      carton = FactoryGirl.build(:carton, :with_fixed_price_total, :with_upcharge)
      expect(carton.valid?).to be_truthy
    end
  end

  describe 'associations' do
    it { should belong_to(:product) }
  end

  describe 'methods' do
    it 'should be active with all fields' do
      c = FactoryGirl.build(:carton)
      expect(c.active?).to be_truthy
    end

    it 'should not be active if missing length' do
      c = FactoryGirl.build(:carton, length: '')
      expect(c.active?).to be_falsey
    end

    it 'should not be active if missing height' do
      c = FactoryGirl.build(:carton, height: '')
      expect(c.active?).to be_falsey
    end

    it 'should not be active if missing width' do
      c = FactoryGirl.build(:carton, width: '')
      expect(c.active?).to be_falsey
    end

    it 'should not be active if missing weight' do
      c = FactoryGirl.build(:carton, weight: '')
      expect(c.active?).to be_falsey
    end

    it 'should not be active if missing quantity' do
      c = FactoryGirl.build(:carton, quantity: 0)
      expect(c.active?).to be_falsey
    end

    it 'should not be active if missing originating zip' do
      c = FactoryGirl.build(:carton, originating_zip: '')
      expect(c.active?).to be_falsey
    end

    it 'should be active with just a fixed_price' do
      c = FactoryGirl.build(:carton, originating_zip: '', fixed_price: 1.0)
      expect(c.active?).to be_truthy
    end

    it 'should produce a valid string' do
      carton = FactoryGirl.build(:carton)
      expect(carton.to_s).to eq '11L x 10W x 12H'
    end

    it 'should produce a valid string with invalid dimensions' do
      carton = FactoryGirl.build(
        :carton,
        width: nil,
        length: nil,
        height: nil
      )
      expect(carton.to_s).to eq '12L x 12W x 12H'
    end
  end
end

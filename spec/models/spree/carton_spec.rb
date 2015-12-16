require 'rails_helper'

RSpec.describe Spree::Carton, type: :model do
  it 'should save with valid values' do
    c = FactoryGirl.build(:carton)
    expect(c.save).to be_truthy
  end

  it 'should belong to an product' do
    t = Spree::Carton.reflect_on_association(:product)
    expect(t.macro).to eq :belongs_to
  end
end

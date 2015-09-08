require 'rails_helper'

RSpec.describe Spree::Address, type: :model do
  it 'should have one ship_user' do
    t = Spree::Address.reflect_on_association(:ship_user)
    expect(t.macro).to eq :has_one
  end

  it 'should have one bill_user' do
    t = Spree::Address.reflect_on_association(:bill_user)
    expect(t.macro).to eq :has_one
  end
end

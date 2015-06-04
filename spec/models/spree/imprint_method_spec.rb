require 'rails_helper'

RSpec.describe Spree::ImprintMethod, type: :model do
  it 'should not create ImprintMethod with nulls' do
    s = Spree::ImprintMethod.new
    expect(s.save).to eq false
  end

  it 'should have many products' do
    t = Spree::ImprintMethod.reflect_on_association(:products)
    expect(t.macro).to eq :has_and_belongs_to_many
  end
end

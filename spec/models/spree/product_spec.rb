require 'rails_helper'

RSpec.describe Spree::Product, type: :model do
  it 'should belong to a supplier' do
    t = Spree::Product.reflect_on_association(:supplier)
    expect(t.macro).to eq :belongs_to
  end

  it 'should have many and belongs to imprint_methods' do
    t = Spree::Product.reflect_on_association(:imprint_methods)
    expect(t.macro).to eq :has_and_belongs_to_many
  end
end

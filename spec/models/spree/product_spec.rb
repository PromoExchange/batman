require 'rails_helper'

RSpec.describe Spree::Product, type: :model do
  it 'should belong to a supplier' do
    # setup
    t = Spree::Product.reflect_on_association(:supplier)

    # exercise
    # verify
    expect(t.macro).to eq :belongs_to
    # teardown
  end

  it 'should have many and belongs to imprint_methods' do
    # setup
    t = Spree::Product.reflect_on_association(:imprint_methods)

    # exercise
    # verify
    expect(t.macro).to eq :has_and_belongs_to_many
    # teardown
  end
end

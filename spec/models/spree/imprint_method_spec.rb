require 'rails_helper'

RSpec.describe Spree::ImprintMethod, type: :model do
  it 'should not create ImprintMethod with nulls' do
    # setup
    s = Spree::ImprintMethod.new
    # exercise
    # verify
    expect(s.save).to eq false
    # teardown
  end

  it 'should have many products' do
    # setup
    t = Spree::ImprintMethod.reflect_on_association(:products)

    # exercise
    # verify
    expect(t.macro).to eq :has_and_belongs_to_many
    # teardown
  end
end

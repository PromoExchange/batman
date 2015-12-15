require 'rails_helper'

RSpec.describe Spree::UpchargeProduct, type: :model do
  it 'should have one product' do
    t = Spree::UpchargeProduct.reflect_on_association(:product)
    expect(t.macro).to eq :belongs_to
  end

  it 'should have one imprint method' do
    t = Spree::UpchargeProduct.reflect_on_association(:imprint_method)
    expect(t.macro).to eq :belongs_to
  end
end

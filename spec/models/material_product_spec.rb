require 'rails_helper'

RSpec.describe MaterialProduct, type: :model do
  it 'should not create MaterialProduct with null values' do
    # setup
    k = MaterialProduct.new
    # exercise
    # verify
    expect(k.save).to eq false
    # teardown
  end

  it 'should create MaterialProduct with a valid values' do
    # setup
    k = MaterialProduct.create( material_id: 1 , product_id: 1)
    # exercise
    # verify
    expect(k.save).to eq true
    # teardown
  end

  it 'should belong to a material' do
    # setup
    t = MaterialProduct.reflect_on_association(:material)

    # exercise
    # verify
    expect(t.macro).to eq :belongs_to
    # teardown
  end

  it 'should belong to a product' do
    # setup
    t = MaterialProduct.reflect_on_association(:product)

    # exercise
    # verify
    expect(t.macro).to eq :belongs_to
    # teardown
  end
end

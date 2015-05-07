require 'rails_helper'

RSpec.describe LineProduct, type: :model do
  it 'should not create LineProduct with a null word' do
    # setup
    k = LineProduct.new
    # exercise
    # verify
    expect(k.save).to eq false
    # teardown
  end

  it 'should create LineProduct with a valid values' do
    # setup
    k = LineProduct.create( line_id: 1 , product_id: 1)
    # exercise
    # verify
    expect(k.save).to eq true
    # teardown
  end

  it 'should belong to a product' do
    # setup
    t = LineProduct.reflect_on_association(:product)

    # exercise
    # verify
    expect(t.macro).to eq :belongs_to
    # teardown
  end

  it 'should belong to a line' do
    # setup
    t = LineProduct.reflect_on_association(:line)

    # exercise
    # verify
    expect(t.macro).to eq :belongs_to
    # teardown
  end
end

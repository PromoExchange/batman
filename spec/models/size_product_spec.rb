# == Schema Information
#
# Table name: products_sizes
#
#  product_id :integer          not null
#  size_id    :integer          not null
#
# Indexes
#
#  index_products_sizes_on_product_id  (product_id)
#  index_products_sizes_on_size_id     (size_id)
#

require 'rails_helper'

RSpec.describe SizeProduct, type: :model do
  it 'should not create SizeProduct with null value' do
    # setup
    k = SizeProduct.new
    # exercise
    # verify
    expect(k.save).to eq false
    # teardown
  end

  it 'should create SizeProduct with a valid values' do
    # setup
    k = SizeProduct.create( size_id: 1 , product_id: 1)
    # exercise
    # verify
    expect(k.save).to eq true
    # teardown
  end

  it 'should belong to a size' do
    # setup
    t = SizeProduct.reflect_on_association(:size)

    # exercise
    # verify
    expect(t.macro).to eq :belongs_to
    # teardown
  end

  it 'should belong to a product' do
    # setup
    t = SizeProduct.reflect_on_association(:product)

    # exercise
    # verify
    expect(t.macro).to eq :belongs_to
    # teardown
  end
end

# == Schema Information
#
# Table name: imagetypes
#
#  id         :integer          not null, primary key
#  image_id   :integer          not null
#  product_id :integer          not null
#  sizetype   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_imagetypes_on_image_id    (image_id)
#  index_imagetypes_on_product_id  (product_id)
#

require 'rails_helper'

RSpec.describe Imagetype, type: :model do
  it 'should not create an image type with a null image_id' do
    # setup
    p = Imagetype.new(product_id: 1, sizetype: 'dd')
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not create an image type with a null product_id' do
    # setup
    p = Imagetype.new(image_id: 1, sizetype: 'dd')
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not create an image type with a null type' do
    # setup
    p = Imagetype.new(image_id: 1, product_id: 1)
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not create an image type with an invalid type' do
    # setup
    p = Imagetype.new(image_id: 1, product_id: 1, sizetype: 'dd')
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should create an image type with an valid values' do
    # setup
    p = Imagetype.new(image_id: 1, product_id: 1, sizetype: 'thumb')
    # exercise
    # verify
    expect(p.save).to eq true
    # teardown
  end

  it 'test factory' do
    # setup
    c = build(:imagetype)
    # exercise
    # verify
    expect(c.sizetype).to eq 'thumb'
    expect(c.image_id).to eq 1
    expect(c.product_id).to eq 1
    # teardown
  end
end

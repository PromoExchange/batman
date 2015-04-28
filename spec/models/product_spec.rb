# == Schema Information
#
# Table name: products
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  description  :string           not null
#  includes     :string
#  features     :string
#  packsize     :integer
#  packweight   :string
#  unit_measure :string
#  leadtime     :string
#  rushtime     :string
#  info         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  supplier_id  :integer          not null
#

require 'rails_helper'

RSpec.describe Product, type: :model do
  it 'should not save a null product' do
    # setup
    p = Product.new

    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should save a valid product' do
    # setup
    p = Product.new(name: 'name', description: 'description')

    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should have many lines' do
    # setup
    t = Product.reflect_on_association(:lines)

    # exercise
    # verify
    expect(t.macro).to eq :has_and_belongs_to_many
    # teardown
  end

  it 'should have many colors' do
    # setup
    t = Product.reflect_on_association(:colors)

    # exercise
    # verify
    expect(t.macro).to eq :has_and_belongs_to_many
    # teardown
  end

  it 'should have many keywords' do
    # setup
    t = Keyword.reflect_on_association(:products)

    # exercise
    # verify
    expect(t.macro).to eq :has_and_belongs_to_many
    # teardown
  end

  it 'test factory' do
    # setup
    p = build(:product)
    # exercise
    # verify

    expect(p.name).to eq 'name'
    expect(p.description).to eq 'description'
    expect(p.includes).to eq 'includes'
    expect(p.features).to eq 'features'
    expect(p.packsize).to eq 1
    expect(p.packweight).to eq 'packweight'
    expect(p.unit_measure).to eq 'unit_measure'
    expect(p.leadtime).to eq 'leadtime'
    expect(p.rushtime).to eq 'rushtime'
    expect(p.info).to eq 'info'

    # teardown
  end
end

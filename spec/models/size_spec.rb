# == Schema Information
#
# Table name: sizes
#
#  id     :integer          not null, primary key
#  name   :string           not null
#  width  :string
#  height :string
#  depth  :string
#  dia    :string
#

require 'rails_helper'

RSpec.describe Size, type: :model do
  it 'should not save size with null name' do
    # setup
    p = Size.new
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should save size with valid values' do
    # setup
    p = Size.new( name: 'name')
    # exercise
    # verify
    expect(p.save).to eq true
    # teardown
  end

  it 'should have many products' do
    # setup
    t = Size.reflect_on_association(:products)

    # exercise
    # verify
    expect(t.macro).to eq :has_and_belongs_to_many
    # teardown
  end

  it 'test factory' do
    # setup
    s = build(:size)
    # exercise
    # verify
    expect(s.name).to eq 'name'
    expect(s.width).to eq 'width'
    expect(s.height).to eq 'height'
    expect(s.depth).to eq 'depth'
    expect(s.dia).to eq 'dia'
    # teardown
  end
end

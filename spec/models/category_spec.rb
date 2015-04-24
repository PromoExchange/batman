# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Category, type: :model do
  it 'should not create category with nulls' do
    # setup
    p = Category.new
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should create category with a valid name and parent' do
    # setup
    p = Category.new
    p.name = 'valid name'
    # exercise
    # verify
    expect(p.save).to eq true
    # teardown
  end

  it 'test factory' do
    # setup
    c = build(:category)
    # exercise
    # verify
    expect(c.name).to eq "CATEGORY"
    # teardown
  end

end

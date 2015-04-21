require 'rails_helper'

RSpec.describe CategoryRelated, type: :model do
  it 'should not create category_related with nulls' do
    # setup
    p = CategoryRelated.new
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should create category_related with valid values' do
    # setup
    p = CategoryRelated.new
    p.category_id = 1
    p.related_id = 1

    # exercise
    # verify
    expect(p.save).to eq true
    # teardown
  end

  it 'should create category_related with valid values' do
    # setup
    c = build(:category_related)

    # exercise
    # verify
    expect(p.category.name).to eq "CATEGORY"
    # teardown
  end
end

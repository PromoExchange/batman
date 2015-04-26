require 'rails_helper'

RSpec.describe Product, type: :model do
  it 'test factory' do
    # setup
    c = build(:product)
    # exercise
    # verify
    is_expected.to monetize(:value_cents)
    expect(c.pricetype).to eq 'base'
    expect(c.effective_date).to eq '1/1/2015'
    expect(c.code).to eq 'A'

    factory :product do
      name 'name'
      description 'description'
      includes 'includes'
      features 'features'
      packsize 1
      packweight 'packweight'
      unit_measure 'unit_measure'
      leadtime 'leadtime'
      rushtime 'rushtime'
      info 'MyString'
    end

    # teardown
  end
end

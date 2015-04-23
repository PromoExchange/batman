require 'rails_helper'

RSpec.describe Line, type: :model do
  it 'should not create Line with a nulls' do
    # setup
    p = Line.new
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should create Line with a brand' do
    # setup
    b = create(:brand)
    # p = Line.new
    l = build(:line, brand_id: b.id )
    # exercise
    # verify
    expect(l.save).to eq true
    # teardown
  end

  it 'test factory' do
    # setup
    c = build(:line)
    # exercise
    # verify
    expect(c.name).to eq 'LINENAME'
    expect(c.brand_id).to eq 1
    # teardown
  end
end

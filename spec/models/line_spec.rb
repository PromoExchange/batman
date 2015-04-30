# == Schema Information
#
# Table name: lines
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  brand_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_lines_on_brand_id  (brand_id)
#

require 'rails_helper'

RSpec.describe Line, type: :model do

  it 'should have many products' do
    # setup
    t = Line.reflect_on_association(:products)

    # exercise
    # verify
    expect(t.macro).to eq :has_and_belongs_to_many
    # teardown
  end

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
    l = build(:line, brand_id: b.id)
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
    # FIXME: This association test, spend some time with factorygirl
    # expect(c.brand_id).to eq 4
    # teardown
  end
end

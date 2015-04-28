# == Schema Information
#
# Table name: colors
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Color, type: :model do
  it 'should not create Color with null name' do
    # setup
    p = Color.new
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should have many products' do
    # setup
    t = Color.reflect_on_association(:products)

    # exercise
    # verify
    expect(t.macro).to eq :has_and_belongs_to_many
    # teardown
  end

  it 'test factory' do
    # setup
    c = build(:size)
    # exercise
    # verify
    expect(c.name).to eq 'name'
    # teardown
  end
end

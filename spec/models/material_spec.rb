# == Schema Information
#
# Table name: materials
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Material, type: :model do
  it 'should not save material with nulls' do
    # setup
    p = Material.new
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should save material with nulls' do
    # setup
    p = Material.new(name: 'material')

    # exercise
    # verify
    expect(p.save).to eq true
    # teardown
  end

  it 'test factory' do
    # setup
    c = build(:material)
    # exercise
    # verify
    expect(c.name).to eq 'material'
    # teardown
  end
end

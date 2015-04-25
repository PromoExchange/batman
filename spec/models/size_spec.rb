# == Schema Information
#
# Table name: sizes
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  width      :string
#  height     :string
#  depth      :string
#  dia        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
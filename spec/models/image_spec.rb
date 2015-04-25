# == Schema Information
#
# Table name: images
#
#  id         :integer          not null, primary key
#  title      :string
#  location   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Image, type: :model do
  it 'should not create Image with nulls' do
    # setup
    p = Image.new
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should not create Image with null location' do
    # setup
    p = Image.new(title: 'title ')
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should create Image with null valid values' do
    # setup
    p = Image.new(title: 'title ', location: 'location')
    # exercise
    # verify
    expect(p.save).to eq true
    # teardown
  end

  it 'test factory' do
    # setup
    c = build(:image)
    # exercise
    # verify
    expect(c.title).to eq 'title'
    expect(c.location).to eq 'location'
    # teardown
  end
end

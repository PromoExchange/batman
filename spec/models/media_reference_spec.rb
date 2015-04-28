# == Schema Information
#
# Table name: media_references
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  location   :string           not null
#  reference  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe MediaReference, type: :model do
  it 'should not save mediareference with nulls' do
    # setup
    p = MediaReference.new
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should save mediareference with null location' do
    # setup
    p = MediaReference.new(name: 'name', reference: 'reference')

    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should save mediareference with null reference' do
    # setup
    p = MediaReference.new(name: 'name', location: 'location')

    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should have many media references' do
    # setup
    t = MediaReference.reflect_on_association(:products)

    # exercise
    # verify
    expect(t.macro).to eq :has_and_belongs_to_many
    # teardown
  end

  it 'test factory' do
    # setup
    c = build(:media_reference)
    # exercise
    # verify
    expect(c.name).to eq 'name'
    expect(c.location).to eq 'catalog'
    expect(c.reference).to eq '347'
    # teardown
  end
end

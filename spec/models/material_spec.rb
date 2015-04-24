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
    p = Material.new( name: 'material')

    # exercise
    # verify
    expect(p.save).to eq true
    # teardown
  end

end

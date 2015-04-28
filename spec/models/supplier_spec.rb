# == Schema Information
#
# Table name: suppliers
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  description :string
#

require 'rails_helper'

RSpec.describe Supplier, type: :model do
  it 'should not save supplier with null name' do
    # setup
    p = Supplier.new()
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end

  it 'should save supplier with valid name' do
    # setup
    p = Supplier.new(name: 'name')
    # exercise
    # verify
    expect(p.save).to eq true
    # teardown
  end
end

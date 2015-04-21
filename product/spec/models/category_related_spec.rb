require 'rails_helper'

RSpec.describe CategoryRelated, type: :model do
  it 'should not create category_related with a nulls' do
    # setup
    p = CategoryRelated.new
    # exercise
    # verify
    expect(p.save).to eq false
    # teardown
  end
end

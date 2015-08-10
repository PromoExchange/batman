require 'rails_helper'

RSpec.describe Spree::TaxRate, type: :model do
  it 'should belong to user' do
    t = Spree::TaxRate.reflect_on_association(:user)
    expect(t.macro).to eq :belongs_to
  end
end

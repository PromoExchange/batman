require 'rails_helper'

RSpec.describe Spree::User, type: :model do
  it 'should have many tax rates' do
    t = Spree::User.reflect_on_association(:tax_rates)
    expect(t.macro).to eq :has_many
  end
end

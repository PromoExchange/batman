require 'rails_helper'

RSpec.describe Spree::User, type: :model do
  it 'should have many tax rates' do
    t = Spree::User.reflect_on_association(:tax_rates)
    expect(t.macro).to eq :has_many
  end

  it 'should return shipping address fullname' do
    u = FactoryGirl.create(:user_with_addresses)
    expect(u.shipping_name).to eq "John Doe"
  end

  it 'should return blank for a nil shipping address' do
    u = FactoryGirl.create(:user)
    expect(u.shipping_name).to eq ""
  end
end

require 'rails_helper'

RSpec.describe Spree::Logo, type: :model do
  xit 'create an image' do
    logo = FactoryGirl.build(:logo)
    expect(logo.save).to be_truthy
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:purchase) }
  end
end

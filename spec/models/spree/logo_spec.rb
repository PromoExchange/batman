require 'rails_helper'

RSpec.describe Spree::Logo, type: :model do
  xit 'create an image' do
    logo = FactoryGirl.build(:logo)
    expect(logo.save).to be_truthy
  end
end

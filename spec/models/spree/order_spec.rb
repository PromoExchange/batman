require 'rails_helper'

RSpec.describe Spree::Order, type: :model do
  describe 'associations' do
    it { should have_one(:purchase) }
  end
end

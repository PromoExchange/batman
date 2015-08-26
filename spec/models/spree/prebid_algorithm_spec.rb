require 'rails_helper'

RSpec.describe Spree::Prebid, type: :model do
  xit 'should apply price discount' do
    discount = 0.50

    ('A'..'K').each do |l|
      auction_data = {
        base_price: 100,
        running_unit_price: 100
      }
      Spree::Prebid.send(:apply_price_discount, auction_data, l)
      expect((discount * 100) - auction_data[:running_unit_price]).to be < 0.0001
    end
  end
end

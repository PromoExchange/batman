class Spree::AuctionSize < ActiveRecord::Base
  serialize :product_size, Hash
end

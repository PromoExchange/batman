class Spree::AuctionPmsColor < Spree::Base
  self.table_name = 'spree_auctions_pms_colors'
  belongs_to :auction
  belongs_to :pms_color
end

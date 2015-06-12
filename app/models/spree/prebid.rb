class Spree::Prebid < Spree::Base
  belongs_to :seller, class_name: 'User'
  belongs_to :product
  has_many :adjustments
  has_many :bids

  # TODO: Cascade delete order

  validates :seller_id, presence: true
  validates :product_id, presence: true

  def create_bids
    # 1/ Auctions that are for this product
    # 2/ That I am not already participating in
    auctions = Spree::Auction.joins(:bids)
      .where( product_id: product_id )

    # Spree::Auction.joins(:bids).where.not( spree_bids: {prebid_id: 1} ).where( product_id: 1 )

    auctions.each do |auction|
      unless auction.bids.where( prebid_id: id ).present?
        auction.bids << Spree::Bid.new( seller_id: seller_id,
          description: 'Prebid generated',
          auction_id: auction.id,
          prebid_id: id)
        auction.save
      end
    end
  end
end

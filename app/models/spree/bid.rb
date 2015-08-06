class Spree::Bid < Spree::Base
  before_create :build_order

  belongs_to :auction
  belongs_to :seller, class_name: 'Spree::User'
  belongs_to :order, dependent: :destroy
  belongs_to :prebid

  validates :auction_id, presence: true
  validates :seller_id, presence: true
  validates_inclusion_of :status, in: %w(open accepted cancelled completed)

  delegate :email, to: :seller

  def bid
    order.total
  end

  def build_order
    o = Spree::Order.create
    self.order_id = o.id
  end

  def seller_fee
    (order.total * seller.px_rate).round(2)
  end
end

class Spree::Bid < Spree::Base
  before_save :build_order, on: :create

  belongs_to :auction
  belongs_to :seller, class_name: 'Spree::User'
  belongs_to :order, dependent: :destroy
  belongs_to :prebid

  validates :auction_id, presence: true
  validates :seller_id, presence: true

  delegate :email, to: :seller

  def bid
    order.total
  end

  def build_order
    o = Spree::Order.create
    self.order_id = o.id
    true
  end
end

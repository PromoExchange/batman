class Spree::Bid < Spree::Base
  scope :open, -> { where(status: :open) }
  scope :accepted, -> { where(status: :accepted) }
  scope :cancelled, -> { where(status: :cancelled) }
  scope :completed, -> { where(status: :completed) }

  before_create :build_order

  belongs_to :auction
  belongs_to :seller, class_name: 'Spree::User'
  belongs_to :order, dependent: :destroy
  belongs_to :prebid

  validates :auction_id, presence: true
  validates :seller_id, presence: true
  validates_inclusion_of :status, in: %w(open accepted cancelled completed)

  state_machine initial: :open do
    event :accept do
      transition open: :accepted
    end

    event :cancel do
      transition open: :cancelled
    end

    event :pay do
      transition accepted: :completed
    end
  end

  delegate :email, to: :seller
  delegate :total, to: :order

  def bid
    order.total
  end

  def build_order
    o = Spree::Order.create
    self.order_id = o.id
  end

  def seller_fee
    rate = 0.0899
    rate = 0.0299 if auction.preferred?(seller)
    (order.total * rate).round(2)
  end
end

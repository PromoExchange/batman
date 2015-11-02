class Spree::Bid < Spree::Base
  before_create :build_order

  belongs_to :auction
  belongs_to :seller, class_name: 'Spree::User'
  belongs_to :order, dependent: :destroy
  belongs_to :prebid

  has_many :auction_payments

  validates :auction_id, presence: true
  validates :seller_id, presence: true

  state_machine initial: :open do
    after_transition on: :non_preferred_accept, do: :notification_for_waiting_confirmation
    after_transition on: :preferred_accept, do: :send_invoice
    after_transition on: [:preferred_accept, :non_preferred_accept], do: :other_bids_lost

    event :preferred_accept do
      transition open: :accepted
    end

    event :non_preferred_accept do
      transition open: :accepted
    end

    event :cancel do
      transition open: :cancelled
    end

    event :lose do
      transition open: :lost
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

  def seller_fee
    rate = 0.0899
    rate = 0.0399 if auction.preferred?(seller)
    (order.total * rate).round(2)
  end

  private

  def notification_for_waiting_confirmation
    Resque.enqueue(
      WaitingForConfirmation,
      auction_id: auction.id,
      email_address: seller.email
    )
    Resque.enqueue_at(
      EmailHelpers.email_delay(Time.zone.tomorrow.midnight),
      ConfirmOrderTimeExpire,
      auction_id: auction.id,
      email_address: seller.email
    )
  end

  def other_bids_lost
    Spree::Bid.where(auction_id: auction.id, state: 'open').find_each(&:lose)
  end

  def send_invoice
    Resque.enqueue(
      SendInvoice,
      auction_id: auction.id
    )
    Resque.enqueue_at(
      EmailHelpers.email_delay(3.days.from_now),
      UnpaidInvoice,
      auction_id: auction.id
    )
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

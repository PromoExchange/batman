class Spree::Bid < Spree::Base
  before_create :build_order

  belongs_to :auction
  belongs_to :seller, class_name: 'Spree::User'
  belongs_to :order, dependent: :destroy
  belongs_to :prebid

  has_many :auction_payments
  has_many :shipping_options, dependent: :destroy

  validates :auction, presence: true
  validates :seller, presence: true

  state_machine initial: :open do
    after_transition on: :non_preferred_accept, do: :send_invoice
    after_transition on: [:preferred_accept, :non_preferred_accept], do: :other_bids_lost

    event :preferred_accept do
      transition open: :accepted
    end

    event :non_preferred_accept do
      transition [:open, :lost] => :accepted
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

    event :reject do
      transition accepted: :rejected
    end
  end

  delegate :email, to: :seller
  delegate :total, to: :order
  delegate :product, to: :auction

  def bid
    order.total
  end

  def seller_fee
    rate = 0.0899
    rate = 0.0399 if auction.preferred?(seller)
    (order.total * rate).round(2)
  end

  def create_payment(token)
    stripe = Stripe::Charge.create(
      amount: (bid.round(2) * 100).to_i,
      currency: 'usd',
      customer: (token ? token : auction.customer.token),
      description: "Auction ID: #{auction.reference}, Buyer: #{auction.buyer.email}"
    )
    if %w(succeeded pending).include?(stripe.status)
      auction_payments.create(
        status: stripe.status,
        charge_id: stripe.id,
        failure_code: stripe.failure_code,
        failure_message: stripe.failure_message
      )
    end
    return stripe.status
  rescue => e
    return e
  end

  def pay_sample_fee
    @product_requests = auction.buyer.product_requests
    @product_requests.each do |product_request|
      product_request.sample_fee if product_request.request_ideas.present?
    end
  end

  def delivery_date
    production_time = product.production_time
    production_time ||= 14
    Time.zone.now + (2 + production_time + delivery_days).days
  end

  private

  def build_order
    o = Spree::Order.create
    self.order_id = o.id
  end

  def other_bids_lost
    Spree::Bid.where(auction_id: auction.id, state: 'open').find_each(&:lose)
  end

  def send_invoice
    Resque.enqueue(SendInvoice, auction_id: auction.id)
  end
end

class Spree::Auction < Spree::Base
  before_create :set_default_dates
  after_create :generate_reference

  has_many :bids, -> { includes(:order).order('spree_orders.total ASC') }

  has_many :auctions_users, class_name: 'Spree::AuctionsUser'
  has_many :invited_sellers, through: :auctions_users, source: :user

  belongs_to :buyer, class_name: 'Spree::User'
  belongs_to :imprint_method
  belongs_to :logo
  belongs_to :main_color, class_name: 'Spree::ColorProduct'
  has_one :order

  has_many :auctions_pms_colors, class_name: 'Spree::AuctionPmsColor'
  has_many :pms_colors, through: :auctions_pms_colors

  belongs_to :product
  belongs_to :shipping_address, class_name: 'Spree::Address'

  has_one :review
  has_one :request_idea

  belongs_to :customer

  accepts_nested_attributes_for :auctions_pms_colors

  has_attached_file :proof_file,
    path: '/proof_file/:id/:basename.:extension'

  validates_attachment_content_type :proof_file,
    content_type: %w(image/jpeg image/jpg image/png image/gif application/pdf)

  validates :buyer_id, presence: true
  validates :logo_id, presence: true, unless: -> do
    imprint_method = Spree::ImprintMethod.find_by(name: 'Blank')
    return true if imprint_method.nil? # Needed for testing, do not seed db:test
    imprint_method_id == imprint_method.id
  end
  validates :main_color_id, presence: true
  validates_inclusion_of :payment_method, in: ['Credit Card', 'Check']
  validates :product_id, presence: true
  validates :imprint_method_id, presence: true
  validates :quantity, presence: true
  validates :shipping_address_id, presence: true
  validates_numericality_of :quantity, only_integer: true
  validates_numericality_of :quantity, greater_than_or_equal_to: -> (auction) do
    50 if auction.product.nil?
    auction.product.minimum_quantity
  end
  validates_inclusion_of :shipping_agent, in: %w(ups fedex)
  validates :customer_id, presence: { message: "Payment Option can't be blank" }, if: -> { payment_method.present? }

  delegate :name, to: :product
  delegate :email, to: :buyer, prefix: true

  # preferred
  #   open
  #   accept -> unpaid
  #   preferred_pay -> complete

  # non preferred
  #   open
  #   accept -> waiting_confirmation
  #   confirm -> in_production
  #   enter_tracking -> confirm_receipt
  #   confirm_receipt -> complete

  #   rate, any time, not really a state
  #   cancel, only valid before accept
  #   end, At the end of the auctions time

  state_machine initial: :open do
    after_transition on: :confirm_order, do: :notification_for_in_production
    after_transition on: :delivered, do: :notification_for_product_delivered
    after_transition on: :delivery_confirmed, do: :notification_for_confirm_received
    after_transition on: :reject_proof, do: :notification_for_reject_proof
    after_transition on: :approve_proof, do: :notification_for_approve_proof
    after_transition on: :upload_proof, do: :notification_for_upload_proof
    after_transition on: :cancel, do: :remove_request_idea
    after_transition on: :delivery_confirmed, do: :rating_reminder

    # TODO: When auction created, schedule job to end it
    event :end do
      transition open: :ended
    end

    event :cancel do
      transition [:open, :waiting_confirmation, :in_dispute] => :cancelled
    end

    event :accept do
      transition open: :waiting_confirmation
    end

    # Technically this is accept for preferred sellers
    # Preferred flow
    event :unpaid do
      transition [:open, :waiting_confirmation] => :unpaid
    end

    event :invoice_paid do
      transition unpaid: :complete
    end

    # Non preferred flow
    event :confirm_order do
      transition [:waiting_confirmation, :unpaid] => :create_proof
    end

    event :upload_proof do
      transition create_proof: :waiting_proof_approval
    end

    event :approve_proof do
      transition waiting_proof_approval: :in_production
    end

    event :reject_proof do
      transition waiting_proof_approval: :create_proof
    end

    event :no_confirm_late do
      transition waiting_confirmation: :open
    end

    event :enter_tracking do
      transition in_production: :send_for_delivery
    end

    event :delivered do
      transition send_for_delivery: :confirm_receipt
    end

    event :order_rejected do
      transition [:confirm_receipt, :send_for_delivery] => :in_dispute
    end

    event :dispute_resolved do
      transition in_dispute: :complete
    end

    event :delivery_confirmed do
      transition [:confirm_receipt, :send_for_delivery] => :complete
    end
  end

  def image_uri
    product.images.empty? ? 'noimage/mini.png' : product.images.first.attachment.url('mini')
  end

  def product_unit_price
    unit_price = product.price
    product.master.volume_prices.each do |v|
      if v.open_ended? || (v.range.to_range.begin..v.range.to_range.end).include?(quantity)
        unit_price = v.amount
        break
      end
    end
    unit_price
  end

  def num_locations
    1
  end

  def num_colors
    pms_colors.count
  end

  def rush?
    false
  end

  def preferred?(seller)
    auctions_users.find_by(user: seller).nil? ? false : true
  end

  def buyer_company
    return '' unless buyer.shipping_address
    buyer.shipping_address.company
  end

  def winning_bid
    Spree::Bid.find_by(auction_id: id, state: %w(accepted completed waiting_confirmation))
  end

  def product_delivered?
    ups_response.is_delivered?
  rescue
    return false
  end

  def reviewed?
    !review.nil?
  end

  def remove_request_idea
    update_attributes(cancelled_date: Time.zone.now)
    request_idea.auction_close! if request_idea.present?
  end

  def ups_response
    ups = ActiveShipping::UPS.new(
      login: ENV['UPS_API_USERID'],
      password: ENV['UPS_API_PASSWORD'],
      key: ENV['UPS_API_KEY']
    )
    ups.find_tracking_info(tracking_number, test: true)
  end

  private

  def notification_for_in_production
    Resque.enqueue(
      InProduction,
      auction_id: id
    )
    Resque.enqueue_at(
      EmailHelpers.email_delay(Time.zone.now + 48.hours),
      SellerFailedUploadProof,
      auction_id: id
    )
    Resque.enqueue_at(
      EmailHelpers.email_delay(Time.zone.now + 48.hours),
      ProofNeededImmediately,
      auction_id: id
    )
  end

  def notification_for_product_delivered
    Resque.enqueue(
      ProductDelivered,
      auction_id: id
    )
    Resque.enqueue_at(
      EmailHelpers.email_delay(Time.zone.now + 3.days),
      ConfirmReceiptReminder,
      auction_id: id
    )
  end

  def notification_for_confirm_received
    Resque.enqueue(
      ConfirmReceived,
      auction_id: id
    )
  end

  def notification_for_reject_proof
    Resque.enqueue(
      RejectProof,
      auction_id: id
    )
    Resque.enqueue_at(
      EmailHelpers.email_delay(Time.zone.now + 48.hours),
      SellerFailedUploadProof,
      auction_id: id
    )
    Resque.enqueue_at(
      EmailHelpers.email_delay(Time.zone.now + 48.hours),
      ProofNeededImmediately,
      auction_id: id
    )
  end

  def notification_for_approve_proof
    Resque.enqueue(
      ApproveProof,
      auction_id: id
    )
    Resque.enqueue_at(
      EmailHelpers.email_delay(Time.zone.now + 15.days),
      TrackingReminder,
      auction_id: id
    )
  end

  def notification_for_upload_proof
    Resque.enqueue(
      UploadProof,
      auction_id: id
    )
    Resque.enqueue_at(
      EmailHelpers.email_delay(Time.zone.now + 24.hours),
      ProofAvailable,
      auction_id: id
    )
  end

  def rating_reminder
    Resque.enqueue_at(
      EmailHelpers.email_delay(Time.zone.now + 3.days),
      RatingReminder,
      auction_id: id
    )
  end

  def generate_reference
    update_column :reference, SecureRandom.hex(3).upcase
  rescue ActiveRecord::RecordNotUnique => e
    @reference_attempts ||= 0
    @reference_attempts += 1
    retry if @reference_attempts < 5
    raise e, 'Retries exhausted'
  end

  def set_default_dates
    self.started = Time.zone.now
    self.ended = started + 21.days
  end
end

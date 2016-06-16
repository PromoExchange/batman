class Spree::Auction < Spree::Base
  before_create :set_default_dates
  after_create :generate_reference

  belongs_to :buyer, class_name: 'Spree::User'
  belongs_to :clone, class_name: 'Spree::Auction'
  belongs_to :customer
  belongs_to :imprint_method
  belongs_to :logo
  belongs_to :main_color, class_name: 'Spree::ColorProduct'
  belongs_to :product
  belongs_to :shipping_address, class_name: 'Spree::Address'
  has_attached_file :proof_file, path: '/proof_file/:id/:basename.:extension'
  has_many :auctions_pms_colors, class_name: 'Spree::AuctionPmsColor'
  has_many :auctions_users, class_name: 'Spree::AuctionsUser'
  has_many :bids, -> { includes(:order).order('spree_orders.total ASC') }, dependent: :destroy
  has_many :invited_sellers, through: :auctions_users, source: :user
  has_many :pms_colors, through: :auctions_pms_colors
  has_one :auction_size
  has_one :order
  has_one :request_idea
  has_one :review
  validates_attachment_content_type :proof_file,
    content_type: %w(image/jpeg image/jpg image/png image/gif application/pdf)
  validates :imprint_method_id, presence: true
  validates :logo_id, presence: true, if: -> { buyer_id.present? }
  validates :main_color_id, presence: true
  validates :product_id, presence: true
  validates :quantity, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: (lambda do |auction|
      50 if auction.product.nil?
      auction.product.minimum_quantity
    end)
  }
  validates :shipping_agent, inclusion: { in: %w(ups fedex), if: -> { buyer_id.present? } }
  validate :pms_colors_presence, unless: (lambda do
    Spree::PmsColorsSupplier.find_by(imprint_method_id: imprint_method_id).nil?
  end)
  validate :pms_colors_presence, unless: -> { imprint_pms_colors_present? || custom_pms_colors.present? }
  validate :shipping_zipcode_presence, if: -> { buyer_id.present? }
  validate :credit_card_presense, if: -> { customer_id.present? }, on: :update

  delegate :custom_product, to: :product
  delegate :email, to: :buyer, prefix: true
  delegate :name, to: :product
  delegate :wearable?, to: :product

  accepts_nested_attributes_for :auctions_pms_colors

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

  # custom_auction
  #   open
  #   custom_auction

  state_machine initial: :open do
    after_transition on: :confirm_order, do: :notification_for_in_production
    after_transition on: :delivered, do: :notification_for_product_delivered
    after_transition on: :delivery_confirmed, do: :notification_for_confirm_received
    after_transition on: :reject_proof, do: :notification_for_reject_proof
    after_transition on: :approve_proof, do: :notification_for_approve_proof
    after_transition on: :upload_proof, do: :notification_for_upload_proof
    after_transition on: :cancel, do: :remove_request_idea
    after_transition on: :delivery_confirmed, do: :rating_reminder
    after_transition on: :no_confirm_late, do: :refund_payment

    # TODO: When auction created, schedule job to end it
    event :end do
      transition open: :ended
    end

    event :custom_auction do
      transition open: :custom_auction
    end

    event :pending_accept do
      transition open: :pending_accept
    end

    event :cancel do
      transition [:open, :waiting_confirmation, :in_dispute] => :cancelled
    end

    event :pending do
      transition open: :pending
    end

    event :accept do
      transition [:open, :waiting, :pending_accept] => :waiting_confirmation
    end

    # Technically this is accept for preferred sellers
    # Preferred flow
    event :unpaid do
      transition [:open, :waiting_confirmation] => :unpaid
    end

    event :invoice_paid do
      transition unpaid: :complete
    end

    event :clone_confirm_order do
      transition [:open, :waiting_confirmation, :unpaid] => :in_production
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
      transition waiting_confirmation: :waiting
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
      if v.open_ended? || (v.range.to_range.begin..v.range.to_range.end).cover?(quantity)
        unit_price = v.amount
        break
      end
    end
    unit_price
  end

  def product_price_code
    price_code = nil
    price_code_count = 0
    product.master.volume_prices.each do |v|
      next unless v.open_ended? || (v.range.to_range.begin..v.range.to_range.end).cover?(quantity)
      price_code = v.price_code

      # It is possible that the price code is actually the entire price code
      # Break it out and select the correct one
      if price_code.length > 1
        price_code_array = Spree::Price.price_code_to_array(price_code)
        if price_code_array.length >= price_code_count
          price_code = price_code_array[price_code_count]
        end
      end
      break
    end
    price_code || 'V'
  end

  def num_locations
    1
  end

  def num_colors
    pms_count = pms_colors.count
    custom_count = 0
    custom_count = custom_pms_colors.split(',').count unless custom_pms_colors.nil?
    pms_count + custom_count
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
    bids.find_by(state: %w(accepted completed))
  end

  def rejected_bid
    bids.find_by(state: %w(rejected))
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

  def auction_sizes
    %w(S M L XL 2XL)
  end

  def bids_status
    {
      waiting_confirmation: 'Awaiting Confirmation',
      unpaid: 'Awaiting Confirmation',
      create_proof: 'Awaiting Virtual Proof',
      waiting_proof_approval: 'View Proof',
      in_production: 'In Production',
      send_for_delivery: 'Track Shipment',
      confirm_receipt: 'Awaiting receipt confirmation',
      in_dispute: 'Order being disputed',
      complete: 'Completed'
    }
  end

  # TODO: Change params to a hash if we add 1 more
  def best_price(options = {})
    options.reverse_merge!(all_shipping: true)

    options[:quantity] ||= product.maximum_quantity

    self.quantity = options[:quantity].to_i
    save!

    # F YOU
    # bids.destroy_all
    Spree::Bid.where(auction_id: id).find_each do |bid|
      bid.order.delete
      bid.delete
    end

    seller_email = ENV['SELLER_EMAIL']
    raise 'Cannot find seller email environment variable' if seller_email.nil?

    seller = Spree::User.find_by(email: seller_email)
    raise "Failed to find company store seller: #{seller_email}" if seller.nil?

    prebid = Spree::Prebid.find_by(supplier: product.original_supplier, seller: seller)
    raise "Failed to find prebid Seller: #{seller.email} Supplier: #{product.original_supplier.name}" if prebid.nil?

    bid_id = nil
    collected_shipping = []

    if options[:all_shipping] == true
      Spree::ShippingOption::OPTION.each do |option|
        save_bid = option[1] == options[:selected_shipping].to_i ? true : false
        bid_data = prebid.create_prebid(
          auction_id: id,
          selected_shipping: option[1],
          save_bid: save_bid
        )
        bid_id = bid_data[:bid_id] if save_bid == true
        collected_shipping << {
          name: bid_data[:service_name],
          total_cost: bid_data[:running_unit_price] * bid_data[:quantity],
          delivery_date: bid_data[:delivery_date],
          delivery_days: bid_data[:delivery_days],
          shipping_option: option[1]
        }
      end
    else
      bid_data = prebid.create_prebid(
        auction_id: id,
        selected_shipping: options[:selected_shipping].to_i,
        save_bid: true
      )
      bid_id = bid_data[:bid_id]
    end

    return nil if bid_id.nil?

    lowest_bid = Spree::Bid.find(bid_id)
    lowest_total = lowest_bid.order.total.to_f

    collected_shipping.each do |option|
      lowest_bid.shipping_options.create(
        name: option[:name],
        delta: (option[:total_cost].to_f - lowest_total).round(2),
        delivery_date: option[:delivery_date],
        delivery_days: option[:delivery_days],
        shipping_option: option[:shipping_option]
      )
    end
    return lowest_bid unless lowest_bid.nil?
    nil
  rescue StandardError => e
    Rails.logger.error("Failed to get best_price #{e}")
    nil
  end

  private

  def notification_for_in_production
    Resque.enqueue(
      InProduction,
      auction_id: id
    )
    return if clone_id
    return if winning_bid.manage_workflow
    Resque.enqueue_at(
      EmailHelper.email_delay(Time.zone.now + 48.hours),
      SellerFailedUploadProof,
      auction_id: id
    )
    Resque.enqueue_at(
      EmailHelper.email_delay(Time.zone.now + 48.hours),
      ProofNeededImmediately,
      auction_id: id
    )
  end

  def notification_for_product_delivered
    Resque.enqueue(
      ProductDelivered,
      auction_id: id
    )
    return if winning_bid.manage_workflow
    Resque.enqueue_at(
      EmailHelper.email_delay(Time.zone.now + 3.days),
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
    return if winning_bid.manage_workflow
    Resque.enqueue_at(
      EmailHelper.email_delay(Time.zone.now + 48.hours),
      SellerFailedUploadProof,
      auction_id: id
    )
    Resque.enqueue_at(
      EmailHelper.email_delay(Time.zone.now + 48.hours),
      ProofNeededImmediately,
      auction_id: id
    )
  end

  def notification_for_approve_proof
    Resque.enqueue(
      ApproveProof,
      auction_id: id
    )
    return if winning_bid.manage_workflow
    Resque.enqueue_at(
      EmailHelper.email_delay(Time.zone.now + 15.days),
      TrackingReminder,
      auction_id: id
    )
  end

  def notification_for_upload_proof
    Resque.enqueue(
      UploadProof,
      auction_id: id
    )
    return if winning_bid.manage_workflow
    Resque.enqueue_at(
      EmailHelper.email_delay(Time.zone.now + 24.hours),
      ProofAvailable,
      auction_id: id
    )
  end

  def rating_reminder
    return if winning_bid.manage_workflow
    Resque.enqueue_at(
      EmailHelper.email_delay(Time.zone.now + 3.days),
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

  def shipping_zipcode_presence
    errors.add(:base, 'A shipping zipcode is required') if ship_to_zip.blank?
  end

  def pms_colors_presence
    errors.add(:base, 'Must select at least one imprint color (standard or custom PMS color)') if pms_colors.empty?
  end

  def refund_payment
    charge_id = winning_bid.auction_payments.where.not(status: 'failed').take.charge_id
    charge = Stripe::Charge.retrieve(charge_id)
    charge.refund unless charge.status == 'failed'
  rescue
    return false
  end

  def imprint_pms_colors_present?
    return false if imprint_method_id.blank?
    Spree::PmsColorsSupplier.where(supplier_id: product.supplier_id).map(&:imprint_method_id).exclude? imprint_method_id
  end

  def credit_card_presense
    return if buyer.customers.map(&:payment_type).include?('cc')
    errors.add(:base, 'At least one Credit Card is required to be on file.')
  end
end

class Spree::ProductRequest < Spree::Base
  before_create :set_request_type

  belongs_to :buyer, class_name: 'Spree::User'
  has_many :request_ideas

  validates :budget_from, presence: true
  validates :budget_to, presence: true, numericality: {
    greater_than: :budget_from,
    if: -> { budget_from.present? && budget_to.present? }
  }
  validates :quantity, presence: true
  validates :request, presence: true
  validates :title, presence: true

  state_machine initial: :open do
    after_transition on: :generate_notification, do: :notification_for_new_request_idea

    event :generate_notification do
      transition open: :complete
    end

    event :pending_notification do
      transition complete: :open
    end
  end

  def notification_for_new_request_idea
    Resque.enqueue(NewRequestIdea, product_request_id: id)
  end

  def sample_fee
    request_ideas.each do |request_idea|
      next unless request_idea.complete? && !request_idea.paid
      description = "Request Idea ID: #{request_idea.id}"
      customer_token = buyer.customers.find_by(payment_type: 'cc').token
      amount = request_idea.cost.round(2) * 100

      stripe = Stripe::Charge.create(
        amount: amount.to_i,
        currency: 'usd',
        customer: customer_token,
        description: description
      )
      next unless %w(succeeded pending).include?(stripe.status)
      request_idea.auction_payments.create(
        status: stripe.status,
        charge_id: stripe.id,
        failure_code: stripe.failure_code,
        failure_message: stripe.failure_message
      )
      request_idea.update_attributes(paid: true)
    end
  end

  private

  def set_request_type
    request_type.gsub!(/[\[\]\"]/, '') if attribute_present?('request_type')
  end
end

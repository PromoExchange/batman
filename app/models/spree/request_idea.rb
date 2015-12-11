class Spree::RequestIdea < Spree::Base
  belongs_to :product_request
  belongs_to :variant, foreign_key: :sku, primary_key: :sku
  belongs_to :auction

  has_many :auction_payments

  validates :sku, presence: true
  validate :validate_product, if: -> { sku.present? }, on: :create

  scope :with_states, -> { where(state: %w(open complete)) }

  state_machine initial: :open do
    after_transition on: :request_sample, do: :notification_for_sample_request

    event :request_sample do
      transition open: :complete
    end

    event :delete do
      transition [:open, :complete] => :cancelled
    end

    event :auction_close do
      transition [:open, :cancelled, :complete] => :closed
    end
  end

  def notification_for_sample_request
    Resque.enqueue(
      SampleRequest,
      request_idea_id: id
    )
  end

  def image_uri
    product_variant.images.empty? ? 'noimage/mini.png' : product_variant.images.first.attachment.url('mini')
  end

  def product_variant
    variant.product
  end

  private

  def validate_product
    errors.add(:sku, 'is invalid') unless Spree::Variant.exists?(sku: sku)
    errors.add(:sku, 'idea already suggested') if Spree::ProductRequest.find(product_request_id).request_ideas.exists?(sku: sku)
  end
end

class Spree::RequestIdea < Spree::Base
  belongs_to :product_request
  belongs_to :product
  belongs_to :auction

  validates :product_id, presence: true
  validate :validate_product_id, if: -> { product_id.present? }, on: :create

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
      transition [:open, :complete] => :closed
    end
  end

  def notification_for_sample_request
    Resque.enqueue(
      SampleRequest,
      request_idea_id: id
    )
  end

  def image_uri
    product.images.empty? ? 'noimage/mini.png' : product.images.first.attachment.url('mini')
  end

  private

  def validate_product_id
    errors.add(:product_id, 'is invalid') unless Spree::Product.exists?(product_id)
    errors.add(:product_id, 'idea already suggested') if Spree::ProductRequest.find(product_request_id).request_ideas.exists?(product_id: product_id)
  end
end

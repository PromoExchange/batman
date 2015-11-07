class Spree::ProductRequest < Spree::Base
  before_create :set_request_type

  has_many :request_ideas
  belongs_to :buyer, class_name: 'Spree::User'

  validates :title, presence: true
  validates :request, presence: true
  validates :quantity, presence: true
  validates :budget, presence: true
  validates :request_type, presence: true

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
    Resque.enqueue(
      NewRequestIdea,
      product_request_id: id
    )
  end

  private

  def set_request_type
    self.request_type.gsub!(/[\[\]\"]/, "") if attribute_present?("request_type")
  end
end

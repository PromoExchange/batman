class Spree::Review < Spree::Base
  belongs_to :user
  belongs_to :auction

  after_save :recalculate_product_rating, if: :approved?

  validates :rating, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 5,
    message: 'You Must Enter Value For Rating'
  }

  scope :approved, -> { where(approved: true) }

  def recalculate_product_rating
    user.recalculate_rating if user.present?
  end
end

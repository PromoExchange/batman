# Use product style (240x240) for logos, saves on additional conversions etc.
class Spree::Logo < Spree::Image
  belongs_to :user
  validates :user_id, presence: true
end

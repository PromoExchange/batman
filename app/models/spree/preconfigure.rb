class Spree::Preconfigure < Spree::Base
  after_save :clear_cache

  belongs_to :product
  belongs_to :buyer, class_name: 'Spree::User'
  belongs_to :imprint_method
  belongs_to :main_color, class_name: 'Spree::ColorProduct'
  belongs_to :logo

  validates :product_id, presence: true
  validates :buyer_id, presence: true
  validates :imprint_method_id, presence: true
  validates :main_color_id, presence: true
  validates :logo_id, presence: true

  delegate :clear_cache, to: :product
end

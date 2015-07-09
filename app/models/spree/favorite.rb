class Spree::Favorite < Spree::Base
  belongs_to :buyer, class_name: 'User'
  belongs_to :product, class_name: 'Product'

  validates :buyer_id, presence: true
  validates :product_id, presence: true

  def image
    product.images.empty? ? 'noimage/small_image.png' : product.images.first.attachment.url('small')
  end

  def self.user_favorites
    Spree::Auctions.where(buyer_id: current_spree_user.id)
  end
end

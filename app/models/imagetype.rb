class Imagetype < ActiveRecord::Base
  validates :image_id, presence: true
  validates :product_id, presence: true
  validates_inclusion_of :sizetype, :in => %w( large medium small thumb zoom )

  # TODO: Write tests for the joins once I get the product model
  belongs_to :image
  # belongs_to :product
end

# == Schema Information
#
# Table name: imagetypes
#
#  id         :integer          not null, primary key
#  image_id   :integer          not null
#  product_id :integer          not null
#  sizetype   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_imagetypes_on_image_id    (image_id)
#  index_imagetypes_on_product_id  (product_id)
#

class Imagetype < ActiveRecord::Base
  validates :image_id, presence: true
  validates :product_id, presence: true
  validates :sizetype, inclusion: %w( large medium small thumb zoom )

  # TODO: Write tests for the joins once I get the product model
  belongs_to :image
  # belongs_to :product
end

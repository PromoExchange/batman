# == Schema Information
#
# Table name: images
#
#  id         :integer          not null, primary key
#  title      :string
#  location   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Image < ActiveRecord::Base
  # TODO: Location needs better definition
  validates :location, presence: true

  has_many :imagetypes

  belongs_to :product

  # This seems odd, but images can be shared across products
  # suppliers do this all the time. i.e. A photo may contain
  # several products and the image is reused.
  # has_many :products, :through => imagetype
end

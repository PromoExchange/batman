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

FactoryGirl.define do
  factory :imagetype do
    image_id 1
    product_id 1
    sizetype 'thumb'
  end
end

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

FactoryGirl.define do
  factory :image do
    title 'title'
    location 'location'
    # TODO: Correct assoc.
    # products {[FactoryGirl.create(:product)]}
  end
end

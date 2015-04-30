# == Schema Information
#
# Table name: sizes
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  width      :string
#  height     :string
#  depth      :string
#  dia        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Size < ActiveRecord::Base
  validates :name, presence: true

  # Products can have many Sizes, Sizes are used by many products
  # i.e. 2015 Q1 catalog, Page 23 can contain several products
  has_and_belongs_to_many :products
end

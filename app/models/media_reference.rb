# == Schema Information
#
# Table name: media_references
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  location   :string           not null
#  reference  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class MediaReference < ActiveRecord::Base
  validates :reference, presence: true
  validates :location, inclusion: %w( website catalog )

  # Products can have many Media References, Media References are
  # used by many products
  # i.e. 2015 Q1 catalog, Page 23 can contain several products
  has_and_belongs_to_many :products
end

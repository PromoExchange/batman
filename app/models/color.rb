# == Schema Information
#
# Table name: colors
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Color < ActiveRecord::Base
  validates :name, presence: true

  # Products can have many colors, colors are used by many products
  has_and_belongs_to_many :products
end

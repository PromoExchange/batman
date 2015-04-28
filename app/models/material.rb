# == Schema Information
#
# Table name: materials
#
#  id   :integer          not null, primary key
#  name :string           not null
#
class Material < ActiveRecord::Base
  validates :name, presence: true

  # Products can have many materials, materials are used by many products
  has_and_belongs_to_many :products
end

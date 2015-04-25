# == Schema Information
#
# Table name: materials
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Material < ActiveRecord::Base
  validates :name, presence: true
  # belongs_to :product
end

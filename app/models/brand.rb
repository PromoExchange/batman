# == Schema Information
#
# Table name: brands
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Brand < ActiveRecord::Base
  validates :name, presence: true
  has_many :lines
end

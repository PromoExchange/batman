# == Schema Information
#
# Table name: products
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  description  :string           not null
#  includes     :string
#  features     :string
#  packsize     :integer
#  packweight   :string
#  unit_measure :string
#  leadtime     :string
#  rushtime     :string
#  info         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Product < ActiveRecord::Base
  validates :name, presence: true
  validates :description, presence: true
  has_and_belongs_to_many :lines
end

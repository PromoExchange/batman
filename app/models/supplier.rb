# == Schema Information
#
# Table name: suppliers
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  description :string
#

# TODO: I doubt if this is going to stay here long, it does not belong
class Supplier < ActiveRecord::Base
  validates :name, presence: true
  has_many :products
end

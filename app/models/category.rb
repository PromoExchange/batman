# == Schema Information
#
# Table name: categories
#
#  id   :integer          not null, primary key
#  name :string
#

class Category < ActiveRecord::Base
  validates :name, presence: true

  # This is a simple taggable solution via a join table
  # TODO: Check out acts_as_taggable gem
  has_many :categoryrelated, foreign_key: 'category_id',
                             class_name: 'CategoryRelated'

  has_many :children, through: :categoryrelated
end

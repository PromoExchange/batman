# == Schema Information
#
# Table name: categories
#
#  id        :integer          not null, primary key
#  name      :string
#  parent_id :integer
#

class Category < ActiveRecord::Base
  validates :name, presence: true
  validates :parent_id, presence: true

  # Switched from many to many via a join table to a simpler approach
  # Children can only have one parent, categories will be unique
  # across many paths in the tree.
  # The display name may be the same but they treated as different
  # categories.
  # For cross cutting and dynamic, I will look to keywords to help
  # Keywords will be a simple tag table.
  has_many :children, class_name: 'Category', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Category', foreign_key: 'parent_id'
end

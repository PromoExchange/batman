# == Schema Information
#
# Table name: keywords
#
#  id   :integer          not null, primary key
#  word :string           not null
#

class Keyword < ActiveRecord::Base
  validates :word, presence: true

  # Products have many keywords, keywords are used by many products
  has_and_belongs_to_many :products
end

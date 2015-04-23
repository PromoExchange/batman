class Keyword < ActiveRecord::Base
  validates :word, presence: true
  # belongs_to :product
end

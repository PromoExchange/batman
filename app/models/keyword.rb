class Keyword < ActiveRecord::Base
  validates :word, presence: true
end

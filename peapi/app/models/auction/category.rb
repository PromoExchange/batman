class Auction::Category < ActiveRecord::Base
  validates :name, presence: true
end

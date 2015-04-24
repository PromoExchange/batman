# == Schema Information
#
# Table name: keywords
#
#  id         :integer          not null, primary key
#  word       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Keyword < ActiveRecord::Base
  validates :word, presence: true
  # belongs_to :product
end

class Country < ActiveRecord::Base
  validates :code_2, presence: true, length: { is: 2}
  validates :code_3, presence: true, length: { is: 3}
  validates :code_numeric, presence: true, length: { is: 3}
  validates :short_name, presence: true
end

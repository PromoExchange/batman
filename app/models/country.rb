# == Schema Information
#
# Table name: countries
#
#  id           :integer          not null, primary key
#  code_2       :string           not null
#  code_3       :string           not null
#  short_name   :string           not null
#  code_numeric :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Country < ActiveRecord::Base
  validates :code_2, presence: true, length: { is: 2 }
  validates :code_3, presence: true, length: { is: 3 }
  validates :code_numeric, presence: true, length: { is: 3 }
  validates :short_name, presence: true
end

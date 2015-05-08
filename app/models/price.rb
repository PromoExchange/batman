# == Schema Information
#
# Table name: prices
#
#  id             :integer          not null, primary key
#  value_cents    :integer          default(0), not null
#  value_currency :string           default("USD"), not null
#  pricetype      :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  lower          :string
#  upper          :string
#  effective_date :datetime         default(Fri, 08 May 2015 12:50:13 UTC +00:00), not null
#  code           :string
#

class Price < ActiveRecord::Base
  validates :pricetype, inclusion: %w( quanity discount base rush )

  # A/P = 50%
  # B/Q = 45%
  # C/R = 40%
  # D/S = 35%
  # E/T = 30%
  # F/U = 25%
  # G/V = 20%
  #
  # X = 0%

  validates :code, inclusion: %w( A B C D E F G X P Q R S T U V )
  monetize :value_cents

  # Products can have many prices, prices are used by many products
  # i.e. 2015 Q1 catalog, Page 23 can contain several products
  has_and_belongs_to_many :products
end

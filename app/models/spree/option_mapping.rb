class Spree::OptionMapping < Spree::Base
  validates :dc_acct_num, presence: true
  validates :dc_name, presence: true
end

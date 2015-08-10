Spree::User.class_eval do
  has_many :logos
  has_many :tax_rates

  def px_rate
    # TODO: Check preferred status
    invited ? 0.0299 : 0.0499
  end
end

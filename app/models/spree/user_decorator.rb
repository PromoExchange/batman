Spree::User.class_eval do
  has_many :logos

  def px_rate
    invited ? 0.0299 : 0.0499
  end
end

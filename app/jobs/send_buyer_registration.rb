module SendBuyerRegistration
  @queue = :buyer_registration

  def self.perform(user)
    @user = Spree::User.find(user['user_id'])
    BuyerMailer.buyer_registration(@user).deliver
  end
end

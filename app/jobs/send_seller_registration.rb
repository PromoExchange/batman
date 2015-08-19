module SendSellerRegistration
  @queue = :seller_registration

  def self.perform(user)
    @user = Spree::User.find(user['user_id'])
    SellerMailer.seller_registration(@user).deliver
  end
end

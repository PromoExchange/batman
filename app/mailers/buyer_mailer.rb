class BuyerMailer < ApplicationMailer
  def buyer_registration(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to PromoExchange!')
  end
end

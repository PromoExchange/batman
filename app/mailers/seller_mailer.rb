class SellerMailer < ApplicationMailer
  def invoice_not_paid(user)
    @user = user
    mail(to: @user.email, subject: 'PromoExchange invoice unpaid')
  end
end

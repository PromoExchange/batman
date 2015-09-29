class BuyerMailer < ApplicationMailer
  def buyer_registration(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to PromoExchange!')
  end

  def in_production(auction)
    @auction = auction
    mail(to: @auction.buyer.email, subject: 'PromoExchange Auction Order In Production')
  end

  def product_delivered(auction)
    @auction = auction
    mail(to: @auction.buyer.email, subject: 'PromoExchange Auction Product Delivered and Project Closed')
  end
end

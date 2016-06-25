class BuyerMailer < ApplicationMailer
  def invoice(auction)
    @uauction = auction
    mail(to: @auction.buyer.email, subject: 'Invoice for PromoExchange Purchase')
  end

  def send_inspire_me_request(inspire_me_request, product_request)
    @inspire_me_request = inspire_me_request
    @product_request = product_request
    mail(subject: 'PromoExchange Company Store Inspire me request')
  end
end

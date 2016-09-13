class BuyerMailer < ApplicationMailer
  def invoice(purchase)
    @purchase = purchase
    mail(to: @purchase.buyer.email, subject: "Invoice for PromoExchange Purchase: #{@purchase.reference}")
  end

  def send_inspire_me_request(inspire_me_request, product_request)
    @inspire_me_request = inspire_me_request
    @product_request = product_request
    mail(subject: 'PromoExchange Company Store Inspire me request')
  end

  def tracking_info(auction)
    @auction = auction
    mail(to: @auction.buyer.email, subject: 'PromoExchange Auction Tracking Information')
  end
end

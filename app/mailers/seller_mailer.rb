class SellerMailer < ApplicationMailer
  def invoice(auction)
    @auction = auction
    mail(subject: "Invoice for PromoExchange Purchase: #{@auction.reference}")
  end
end

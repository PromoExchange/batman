class SellerMailer < ApplicationMailer
  def invoice(purchase)
    @purchase = purchase
    mail(subject: "Invoice for PromoExchange Purchase: #{@purchase.reference}")
  end
end

class SellerMailer < ApplicationMailer
  def invoice(purchase, payment_email)
    @purchase = purchase
    @payment_email = payment_email
    mail(subject: "Invoice for PromoExchange Purchase: #{@purchase.reference}")
  end
end

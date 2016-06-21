class BuyerMailer < ApplicationMailer
  def ideation_request(product_request)
    @product_request = product_request
    mail(subject: 'PromoExchange product Ideation Request')
  end

  def new_request_idea(product_request)
    @product_request = product_request
    mail(to: @product_request.buyer.email, subject: 'You have new product ideas from PromoExchange!')
  end

  def send_inspire_me_request(inspire_me_request, product_request)
    @inspire_me_request = inspire_me_request
    @product_request = product_request
    mail(subject: 'PromoExchange Company Store Inspire me request')
  end
end

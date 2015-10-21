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

  def confirm_receipt_reminder(auction)
    @auction = auction
    mail(to: @auction.buyer.email, subject: 'PromoExchange Confirm order receipt reminder')
  end

  def upload_proof(auction)
    @auction = auction
    attachments["#{@auction.proof_file_file_name}"] = open("#{@auction.proof_file.url}").read
    mail(to: @auction.buyer.email, subject: 'PromoExchange Auction Proof is available')
  end

  def proof_available(auction)
    @auction = auction
    attachments["#{@auction.proof_file_file_name}"] = open("#{@auction.proof_file.url}").read
    mail(to: @auction.buyer.email, subject: 'PromoExchange Auction Proof is available')
  end

  def sample_request(request_idea)
    @request_idea = request_idea
    mail(to: 'michael.goldstein@thepromoexchange.com', subject: 'PromoExchange Sample Request')
  end

  def new_request_idea(product_request)
    @product_request = product_request
    mail(to: @product_request.buyer.email, subject: 'You have new product ideas from PromoExchange!')
  end

  def rating_reminder(auction)
    @auction = auction
    mail(to: @auction.buyer.email, subject: 'PromoExchange Rating Reminder')
  end
end

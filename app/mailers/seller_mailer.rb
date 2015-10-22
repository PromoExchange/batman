class SellerMailer < ApplicationMailer
  def invoice_not_paid(user)
    @user = user
    mail(to: @user.email, subject: 'PromoExchange invoice unpaid')
  end

  def initial_invoice(auction)
    @auction = auction
    mail(to: @auction.winning_bid.email, subject: 'PromoExchange invoice')
  end

  def seller_registration(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to PromoExchange!')
  end

  def seller_invite(auction, type, email_address)
    @auction = auction
    @type = type
    @email_address = email_address
    @buyer = @auction.buyer.bill_address
    mail(to: @email_address, subject: 'PromoExchange Auction Invite')
  end

  def waiting_for_confirmation(auction)
    @auction = auction
    mail(to: @auction.winning_bid.email, subject: 'PromoExchange Auction waiting for your confirmation')
  end

  def confirm_order_time_expire(auction)
    @auction = auction
    mail(
      to: [@auction.winning_bid.email, 'michael.goldstein@thepromoexchange.com'],
      subject: 'PromoExchange Auction Withdrawal Due to Unresponsiveness'
    )
  end

  def tracking_reminder(auction)
    @auction = auction
    mail(to: @auction.winning_bid.email, subject: 'PromoExchange Auction tracking number reminder')
  end

  def product_delivered(auction)
    @auction = auction
    mail(to: @auction.winning_bid.email, subject: 'PromoExchange Auction Product Delivered')
  end

  def confirm_received(auction)
    @auction = auction
    mail(to: @auction.winning_bid.email, subject: 'PromoExchange Auction Product Confirm Received')
  end

  def claim_payment(auction)
    @auction = auction
    mail(to: @auction.winning_bid.email, subject: 'PromoExchange Auction Claim Payment')
  end

  def claim_payment_request(params, auction)
    @auction = auction
    @params = params
    mail(to: 'michael.goldstein@thepromoexchange.com', subject: 'PromoExchange Claim Payment Request')
  end

  def reject_proof(auction)
    @auction = auction
    mail(to: @auction.winning_bid.email, subject: 'PromoExchange Auction Proof Rejected')
  end

  def approve_proof(auction)
    @auction = auction
    mail(to: @auction.winning_bid.email, subject: 'PromoExchange Auction Proof Approve')
  end

  def seller_failed_upload_proof(auction)
    @auction = auction
    mail(to: 'michael.goldstein@thepromoexchange.com', subject: 'PromoExchange Auction Seller failure to upload proof')
  end

  def proof_needed_immediately(auction)
    @auction = auction
    mail(to: @auction.winning_bid.email, subject: 'PromoExchange Auction Proof needed immediately')
  end

  def review_rating(auction)
    @auction = auction
    mail(to: @auction.winning_bid.email, subject: 'PromoExchange Auction Rate Seller')
  end
end

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
end

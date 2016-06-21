class SellerMailer < ApplicationMailer
  def waiting_for_confirmation(auction)
    @auction = auction
    attachments[@auction.logo.logo_file_file_name.to_s] = open(@auction.logo.logo_file.url.to_s).read
    mail(to: @auction.winning_bid.email, subject: 'PromoExchange Auction waiting for your confirmation')
  end
end

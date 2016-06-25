require 'rails_helper'

RSpec.describe SellerMailer, type: :mailer do
  let(:auction) { FactoryGirl.create(:auction) }
  let(:waiting_for_confirmation_mail) { SellerMailer.waiting_for_confirmation(auction) }

  it 'renders the waiting_for_confirmation email' do
    expect(waiting_for_confirmation_mail.to).to eql([auction.winning_bid.email])
  end
end

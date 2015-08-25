require 'rails_helper'

RSpec.describe SellerMailer, type: :mailer do
  let(:user) { FactoryGirl.create(:user) }
  let(:auction) { FactoryGirl.create(:auction) }
  let(:invoice_not_paid_mail) { SellerMailer.invoice_not_paid(user) }
  let(:initial_invoice_mail) { SellerMailer.initial_invoice(user) }
  let(:seller_registration_mail) { SellerMailer.seller_registration(user) }

  # Not paid
  it 'renders the not paid receiver email' do
    expect(invoice_not_paid_mail.to).to eql([user.email])
  end

  it 'renders the not paid sender email' do
    expect(invoice_not_paid_mail.from).to eql(['hello@thepromoexchange.com'])
  end
end

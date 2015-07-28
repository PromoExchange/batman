require 'rails_helper'

RSpec.describe SellerMailer, type: :mailer do
  let(:user) { FactoryGirl.create(:user) }
  let(:mail) { SellerMailer.invoice_not_paid(user) }

  it 'renders the receiver email' do
    expect(mail.to).to eql([user.email])
  end

  it 'renders the sender email' do
    expect(mail.from).to eql(['support@thepromoexchange.com'])
  end

  it 'assigns @name' do
    expect(mail.body.encoded).to match('Waiting on final format')
  end
end

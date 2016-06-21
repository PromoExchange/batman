class SendRequestMailer < ApplicationMailer
  def request_to_learn_more(email)
    @user_email = email
    mail(from: @user_email, subject: 'PromoExchange Want to learn more')
  end
end

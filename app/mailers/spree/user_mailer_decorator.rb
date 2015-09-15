Spree::UserMailer.class_eval do
  layout 'mailer'

  def confirmation_instructions(user, token, opts={})
    host = Rails.env.test? ? "localhost:3000" : Spree::Store.current.url
    from_email = "hello@thepromoexchange.com"
    @confirmation_url = spree.spree_user_confirmation_url(:confirmation_token => token, :host => host)
    @user = user
    mail to: @user.email, from: from_email, subject: "PromoExchange Confirmation Instructions!"
  end

end

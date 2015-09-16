Spree::UserMailer.class_eval do
  def confirmation_instructions(user, token, _opts = {})
    host = Rails.env.test? ? 'localhost:3000' : Spree::Store.current.url
    from_email = Rails.env.test? ? 'spree@example.com' : from_address
    @confirmation_url = spree.spree_user_confirmation_url(
      confirmation_token: token,
      host: host
    )

    mail to: user.email, from: from_email, subject: host + ' ' + I18n.t(:subject, :scope => [:devise, :mailer, :confirmation_instructions])
  end
end

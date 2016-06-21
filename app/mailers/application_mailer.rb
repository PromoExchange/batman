class ApplicationMailer < ActionMailer::Base
  default from: 'hello@thepromoexchange.com', to: 'michael.goldstein@thepromoexchange.com'
  layout 'mailer'
end

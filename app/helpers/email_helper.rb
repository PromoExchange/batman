module EmailHelper
  def self.email_delay(delay)
    return delay if ENV['EMAIL_DELAY_TESTMODE'].nil?
    Time.zone.now + ENV['EMAIL_DELAY_TESTMODE'].to_i.seconds
  end
end

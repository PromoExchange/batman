module EmailHelpers
  def self.email_delay(delay)
    return delay unless (ENV['EMAIL_DELAY_TESTMODE'] == '1')
    Time.zone.now + 10.seconds
  end
end

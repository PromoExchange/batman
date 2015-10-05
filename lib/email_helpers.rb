module EmailHelpers
  def self.email_delay(delay)
    return delay if ENV['EMAIL_DELAY_TESTMODE'].nil?
    seconds_to_delay = ENV['EMAIL_DELAY_TESTMODE'].to_i
    Time.zone.now + seconds_to_delay.seconds
  end
end

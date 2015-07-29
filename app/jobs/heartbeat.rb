module Heartbeat
  @queue = :heartbeat

  def self.perform
    Rails.logger.info 'Heartbeat: scheduler still running'
  end
end

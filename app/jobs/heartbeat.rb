module Heartbeat
  @queue = :heartbeat

  def self.perform
    logger.info 'Heartbeat: scheduler still running'
  end
end

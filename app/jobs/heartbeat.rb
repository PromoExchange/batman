module Heartbeat
  @queue = :heartbeat

  def self.perform
    puts 'Heartbeat: scheduler still running'
  end
end

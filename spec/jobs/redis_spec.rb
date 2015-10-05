require 'rails_helper'

describe 'Redis tests' do
  it 'should access redis' do
    REDIS.set('foo', 'bar')
    v = REDIS.get('foo')
    expect(v).to eq 'bar'
  end

  it 'should schedule a job' do
    Resque.enqueue_at(EmailHelpers.email_delay(5.days.from_now), Heartbeat, test_id: 5)
    Resque::Scheduler.clear_schedule!
  end
end

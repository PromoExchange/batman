# N.B. ENV['SLACK_CHANNEL'] SHOULD NOT BE PREFIXED WITH # - i.e. use foobar for channel #foobar
SLACK = Slack::Notifier.new ENV['SLACK_URL'], channel: "##{ENV['SLACK_CHANNEL'].blank? ? "px-orders" : ENV['SLACK_CHANNEL']}"

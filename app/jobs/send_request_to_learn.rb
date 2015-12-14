module SendRequestToLearn
  @queue = :send_request_to_learn

  def self.perform(email)
    SendRequestMailer.request_to_learn_more(email).deliver if email.present?
  end
end

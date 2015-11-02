module ConfirmCheckingAccount
  @queue = :confirm_checking_account

  def self.perform(params)
    @customer = Spree::Customer.find(params['customer_id'])
    if @customer.status == 'new'
      BuyerMailer.confirm_checking_account(@customer).deliver

      Resque.enqueue_at(
        EmailHelpers.email_delay(Time.zone.now + 3.days),
        ConfirmCheckingAccount,
        customer_id:  @customer.id
      )
    end

  end  
end
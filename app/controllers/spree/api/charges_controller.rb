class Spree::Api::ChargesController < Spree::Api::BaseController
  def index
    @customers = current_spree_user.customers
    if params[:type] == 'credit_card'
      customers = @customers.credit_card
    else
      customers = @customers.web_check.verified
    end
    render nothing: true, status: :ok, json: customers
  end

  def charge
    auction = Spree::Auction.find(params[:auction_id])
    bid = auction.winning_bid
    amount = bid.seller_fee.round(2) * 100

    description = "Auction ID: #{bid.auction.reference}, Seller: #{bid.seller.email}"

    begin
      Stripe::Charge.create(
        amount: amount.to_i,
        currency: 'usd',
        source: params[:token],
        description: description
      )

      Rails.logger.info("CHARGE: Seller pays C:#{amount.to_i}, D:#{description}")

      bid.transaction do
        bid.update_attributes(state: 'completed')
        bid.auction.update_attributes(state: 'completed')
        bid.order.update_attributes(payment_state: 'completed')
      end
      Spree::OrderUpdater.new(bid.order).update

      redirect_to main_app.dashboards_path, flash: { notice: 'Credit card charged sucessfully' }
    rescue Stripe::CardError => _e
      redirect_to main_app.dashboards_path, flash: { error: 'Error occurred processing charge' }
    end
  end

  def create_customer
    stripe_customer = Stripe::Customer.create(
      source: params[:token],
      description: "User Name : #{current_spree_user.shipping_name}",
      email: current_spree_user.email
    )

    brand = (params[:payment_type] == 'cc' ? stripe_customer.sources.data.first.brand : params[:nick_name])
    status = (params[:payment_type] == 'wc' ? stripe_customer.sources.data.first.status : 'cc')

    customer = Spree::Customer.create(
      user_id: current_spree_user.id,
      token: stripe_customer.id,
      brand: brand,
      last_4_digits: stripe_customer.sources.data.first.last4,
      payment_type: params[:payment_type],
      status: status,
      active_cc: params[:active_cc] ||= false
    )

    if params[:payment_type] == 'wc'
      Resque.enqueue_at(
        EmailHelpers.email_delay(Time.zone.now + 3.days),
        ConfirmCheckingAccount,
        customer_id:  customer.id
      )
    end

    render nothing: true, status: :ok, json: stripe_customer
  rescue
    render nothing: true, status: :internal_server_error
  end

  def delete_customer
    customer = Spree::Customer.find(params[:customer_id])
    cu = Stripe::Customer.retrieve(customer.token)

    customer.delete if cu.delete

    render nothing: true, status: :ok
  rescue
    render nothing: true, status: :internal_server_error
  end

  def confirm_deposit
    customer = Stripe::Customer.retrieve(params[:customer_id])
    bank_id = customer.sources.data.first.id
    amount = "amounts[]=#{params[:amount_first]}&amounts[]=#{params[:amount_second]}"
    auth = { username: ENV['STRIPE_SECRET_KEY'] }
    response = HTTParty.post(
      "https://api.stripe.com/v1/customers/#{customer.id}/sources/#{bank_id}/verify?#{amount}",
      basic_auth: auth
    )

    if response['status'].present?
      Spree::Customer.find_by_token(customer.id).update(status: response['status'])
    end
    render nothing: true, status: :ok, json: response
  rescue
    render nothing: true, status: :internal_server_error
  end

  private

  def charge_params
    params.require(:charge).permit(:token, :auction_id)
  end
end

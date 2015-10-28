class  Spree::Api::ChargesController < Spree::Api::BaseController
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
    customer = Stripe::Customer.create(
      source: params[:token],
      description: "User Name : #{current_spree_user.shipping_address.full_name}",
      email: current_spree_user.email
    )

    Spree::Customer.create(
      user_id: current_spree_user.id,
      token: customer.id,
      brand: customer.sources.data.first.brand,
      last_4_digits: customer.sources.data.first.last4
    )

    render nothing: true, status: :ok
  rescue
    render nothing: true, status: :internal_server_error
  end

  def delete_customer
    customer = Spree::Customer.find(params[:customer_id])
    cu = Stripe::Customer.retrieve(customer.token)
    if cu.delete
      customer.delete 
    else
      render json: { nothing: true, status: :ok, error_msg: 'Not Delete' }
    end
    render json: { nothing: true, status: :ok, error_msg: '' }
  rescue
    render json: { nothing: true, status: :internal_server_error }
  end

  private

  def charge_params
    params.require(:charge).permit(:token, :auction_id)
  end
end

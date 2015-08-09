class  Spree::Api::ChargesController < Spree::Api::BaseController
  def charge
    bid = Spree::Bid.find(params[:bid_id])
    amount = bid.seller_fee.round(2) * 100

    description = "Auction ID: #{bid.auction.reference}, Seller: #{bid.seller.email}"

    begin
      Stripe::Charge.create(
        amount: amount.to_i,
        currency: 'usd',
        source: params[:token],
        description: description
      )

      @bid = Spree::Bid.find(params[:bid_id])
      @bid.transaction do
        @bid.update_attributes(status: 'completed')
        @bid.auction.update_attributes(status: 'completed')
        @bid.order.update_attributes(payment_state: 'completed')
      end
      Spree::OrderUpdater.new(@bid.order).update

      redirect_to main_app.dashboards_path, flash: { notice: 'Credit card charged sucessfully' }
    rescue Stripe::CardError => _e
      redirect_to main_app.dashboards_path, flash: { error: 'Error occurred processing charge' }
    end
  end

  private

  def charge_params
    params.require(:charge).permit(:token, :bid_id)
  end
end

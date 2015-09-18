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

  def buyer_charges
    auction = Spree::Auction.find(params[:auction_id])
    win_bid = auction.winning_bid

    description = "Auction ID: #{auction.reference}, Buyer: #{auction.buyer.email}"

    begin
      Stripe::Charge.create(
        amount: win_bid.bid.to_i,
        currency: 'usd',
        source: params[:token],
        description: description
      )
      auction.update_attributes(state: 'waiting_confirmation')

      redirect_to main_app.dashboards_path, flash: { notice: 'Credit card charged sucessfully' }
    rescue Stripe::CardError => _e
      redirect_to main_app.dashboards_path, flash: { error: 'Error occurred processing charge' }
    end
  end

  private

  def charge_params
    params.require(:charge).permit(:token, :auction_id)
  end
end

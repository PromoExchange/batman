class Spree::Prebid < Spree::Base
  belongs_to :seller, class_name: 'User'
  belongs_to :product
  has_many :adjustments
  has_many :bids

  validates :seller_id, presence: true
  validates :product_id, presence: true

  def create_prebid(auction_id)
    Rails.logger.info 'Prebid: creating prebid'

    auction = Spree::Auction.find(auction_id)

    return if auction.bids.where(prebid_id: id).present?

    # Get Base price from Volume pricing
    base_unit_price = auction.product_unit_price
    running_unit_price = base_unit_price

    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - base_unit_price=#{base_unit_price}")
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - quantity=#{auction.quantity}")

    # Apply discount to base price
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - Vitronic hack, all prices have C discount code")
    running_unit_price = Spree::Price.discount_price('C', base_unit_price)
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - running_unit_price=#{running_unit_price}")

    # Run cost added to unit price
    # Supplier level
    supplier_upcharges = Spree::UpchargeSupplier.where(related_id: 1)
      .includes(:upcharge_type)
      .pluck(
        'spree_upcharge_types.id',
        'spree_upcharge_types.name',
        :price_code,
        :value
      )

    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - supplier_upcharges.count=#{supplier_upcharges.count}")

    supplier_upcharges.each do |s|
      supplier_upcharge_value = 0.0
      Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - supplier_upcharges.value=#{s[1]}")
      case s[1]
      when 'pms_color_match'
        Rails.logger.debug(
          "PREBID - A:#{auction_id} P:#{id} - pms_color_match, auction.pms_color_match=#{auction.pms_color_match}"
        )
        if auction.pms_color_match?
          supplier_upcharge_value = Spree::Price.discount_price(s[2], s[3].to_f)
        end
      when 'ink_change'
        Rails.logger.debug(
          "PREBID - A:#{auction_id} P:#{id} - ink_change, auction.change_ink=#{auction.change_ink}"
        )
        if auction.change_ink?
          supplier_upcharge_value = Spree::Price.discount_price(s[2], s[3].to_f)
        end
      when 'no_under_over'
        Rails.logger.debug(
          "PREBID - A:#{auction_id} P:#{id} - no_under_over, auction.no_under_over=#{auction.no_under_over}"
        )
        if auction.no_under_over?
          supplier_upcharge_value = Spree::Price.discount_price(s[2], s[3].to_f)
        end
      else
        Rails.logger.error("PREBID - A:#{auction_id} P:#{id} - Error, unknown supplier upcharge=#{s[1]}")
      end

      running_unit_price += (supplier_upcharge_value / auction.quantity)
      Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - running_unit_price=#{running_unit_price}")
    end

    # Product level
    product_upcharges = Spree::UpchargeProduct.where(
      related_id: auction.product.id,
      imprint_method_id: auction.imprint_method_id
    ).includes(:upcharge_type)
      .pluck(
        'spree_upcharge_types.id',
        'spree_upcharge_types.name',
        :actual,
        :price_code,
        :value
      )

    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - product_run_charge_count=#{product_upcharges.count}")

    # Decoration cost added to unit price
    # PMS Color match added to unit price
    # Setup cost added to unit price
    product_upcharges.each do |c|
      Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - upcharge=#{c[2]}")

      upcharge_value = c[4].to_f
      Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - upcharge_value=#{upcharge_value}")

      # TODO: parse price code string for ranges
      discounted_upcharge_value = Spree::Price.discount_price('G',c[4].to_f)
      per_unit_product_run_charge = c[4].to_f / auction.quantity

      Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - per_unit_product_run_charge=#{per_unit_product_run_charge}")

      running_unit_price += per_unit_product_run_charge
      Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - running_unit_price=#{running_unit_price}")
    end
    # Additional costs added to unit price

    # Apply tax from raxrate table (check for post shipping)

    # Shipping based on buyers zip

    # Seller markup
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - markup=#{markup.to_f}")
    running_unit_price /= (1 - markup.to_f)
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - running_unit_price=#{running_unit_price}")

    # Promo exchange commission
    px_commission = seller.px_rate.to_f
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - px_commission=#{px_commission}")
    running_unit_price /= (1 - px_commission)
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - running_unit_price=#{running_unit_price}")

    # Payment processing cost
    if auction.payment_method == 'Check'
      payment_processing_commission = 0.015
    else
      payment_processing_commission = 0.0299
    end

    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - payment_processing_commission=#{payment_processing_commission}")
    running_unit_price *= (1 + payment_processing_commission)
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - running_unit_price=#{running_unit_price}")

    Spree::Bid.transaction do
      bid = Spree::Bid.create(
        seller_id: seller_id,
        auction_id: auction.id,
        prebid_id: id
      )

      li = Spree::LineItem.create(
        currency: 'USD',
        order_id: bid.order.id,
        quantity: bid.auction.quantity,
        variant: bid.auction.product.master
      )

      li.price = running_unit_price
      li.save!

      order_updater = Spree::OrderUpdater.new(bid.order)
      order_updater.update

      bid.save
    end
  end
end

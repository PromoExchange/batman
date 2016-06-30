module Spree::QuoteCalculatorUpcharge
  def apply_product_upcharges
    product_upcharges = Spree::UpchargeProduct.where(
      related_id: product.id,
      imprint_method_id: imprint_method.id
    ).includes(:upcharge_type)
      .order(:position)
      .pluck(
        'spree_upcharge_types.id',
        'spree_upcharge_types.name',
        :actual,
        :price_code,
        :value,
        :range
      )
    product_upcharges.each do |product_upcharge|
      # [0] = 'spree_upcharge_types.id',
      # [1] = 'spree_upcharge_types.name',
      # [2] = :actual,
      # [3] = :price_code,
      # [4] = :value
      # [5] = :range

      price_code = product_upcharge[3].gsub(/[1-9]/, '')

      in_range = false
      unless product_upcharge[5].blank?
        bounds = []
        # Is it open ended
        if product_upcharge[5].include? '+'
          bounds[0] = product_upcharge[5].gsub(/([()])|\+/, '').to_i
          bounds[1] = bounds[0] * 2
        else
          bounds = product_upcharge[5].gsub(/[()]/, '').split('..').map(&:to_i)
        end
        range = Range.new(bounds[0], bounds[1])
        in_range = range.member?(quantity)
      end

      case product_upcharge[1]
      when 'setup'
        setup_charge = product_upcharge[4].to_f
        num_setups = [num_colors, 1].max
        (1..num_setups).each do
          self.unit_price += (
            Spree::Price.discount_price(price_code, setup_charge) /
              quantity
          )
        end
        log("Applying #{num_setups} setups")
        log("Charge: #{setup_charge}")
        log("Price code: #{price_code}")
        log("Discounted Charge: #{Spree::Price.discount_price(price_code, setup_charge)}")
        log("After applying charge unit cost: #{self.unit_price}")
      when 'run'
        next unless in_range
        run_charge = product_upcharge[4].to_f
        self.unit_price += Spree::Price.discount_price(price_code, run_charge)
        log('Applying run charge')
        log("Charge: #{run_charge}")
        log("Price code: #{price_code}")
        log("Discounted Charge: #{Spree::Price.discount_price(price_code, run_charge)}")
        log("After applying charge unit cost: #{self.unit_price}")
      when 'additional_location_run'
        next unless in_range
        if auction_data[:num_locations] > 1
          additional_location_charge = product_upcharge[4].to_f
          self.unit_price += Spree::Price.discount_price(price_code, additional_location_charge)
          log('Applying additional location charge')
          log("Charge: #{additional_location_charge}")
          log("Price code: #{price_code}")
          discount_price = Spree::Price.discount_price(price_code, additional_location_charge)
          log("Discounted Charge: #{discount_price}")
          log("After Run applied unit cost: #{unit_price}")
        end
      when 'second_color_run', 'additional_color_run', 'multiple_color_run'
        next unless in_range
        if auction_data[:num_colors] > 1
          multiple_colors_charge = product_upcharge[4].to_f
          (2..auction_data[:num_colors].to_i).each do
            self.unit_price += Spree::Price.discount_price(price_code, multiple_colors_charge)
          end
          log("Applying #{auction_data[:num_colors].to_i - 1} additional color charges")
          log("Charge: #{multiple_colors_charge}")
          log("Price code: #{price_code}")
          discount_price = Spree::Price.discount_price(price_code, multiple_colors_charge)
          log("Discounted Charge: #{discount_price}")
          log("After Run applied unit cost: #{self.unit_price}")
        end
      when 'rush'
        # No ranges
        rush_charge = product_upcharge[4].to_f
        auction_data[:running_unit_price] += (
          Spree::Price.discount_price(price_code, rush_charge) / quantity
        )
        log('Applying Rush charges')
        log("Charge: #{rush_charge}")
        log("Price code: #{price_code}")
        log("Discounted Charge: #{Spree::Price.discount_price(price_code, rush_charge)}")
        log("After Rush applied unit cost: #{self.unit_price}")
      end
    end
  end
end

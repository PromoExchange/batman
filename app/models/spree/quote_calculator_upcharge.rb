module Spree::QuoteCalculatorUpcharge
  def apply_product_upcharges
    product_upcharges = Spree::UpchargeProduct.where(
      related_id: product.id,
      imprint_method_id: imprint_method.id
    ).includes(:upcharge_type)
      .order(:position)
      .pluck_to_hash(:name, :price_code, :value, :range, :apply_count)

    product_upcharges.each do |product_upcharge|
      price_code = product_upcharge[:price_code].gsub(/[1-9]/, '')

      in_range = false
      unless product_upcharge[:range].blank?
        bounds = []
        # Is it open ended
        if product_upcharge[:range].include? '+'
          bounds[0] = product_upcharge[:range].gsub(/([()])|\+/, '').to_i
          bounds[1] = product.maximum_quantity * 2
        else
          bounds = product_upcharge[:range].gsub(/[()]/, '').split('..').map(&:to_i)
        end
        in_range = Range.new(bounds[0], bounds[1]).member?(quantity)
      end

      log("Apply Count: #{product_upcharge[:apply_count]}")

      (product_upcharge[:apply_count] || 1).times do |current_application|
        log("Current application : #{current_application + 1}")

        case product_upcharge[:name]
        when 'less_than_minimum'
          next unless in_range
          less_than_minimum_surcharge = product_upcharge[:value].to_f
          self.unit_price += (
            Spree::Price.discount_price(price_code, less_than_minimum_surcharge) /
              quantity
          )
          log('Applying less than minimum surcharge')
          log("Surcharge: #{less_than_minimum_surcharge}")
          log("Price code: #{price_code}")
          log('Discounted Surcharge: '\
            "#{Spree::Price.discount_price(price_code, less_than_minimum_surcharge)}")
          log("After applying surcharge unit cost: #{self.unit_price}")
        when 'setup'
          setup_charge = product_upcharge[:value].to_f
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
          run_charge = product_upcharge[:value].to_f
          self.unit_price += Spree::Price.discount_price(price_code, run_charge)
          log('Applying run charge')
          log("Charge: #{run_charge}")
          log("Price code: #{price_code}")
          log("Discounted Charge: #{Spree::Price.discount_price(price_code, run_charge)}")
          log("After applying charge unit cost: #{self.unit_price}")
        when 'additional_location_run'
          next unless in_range
          if num_locations > 1
            additional_location_charge = product_upcharge[:value].to_f
            self.unit_price += Spree::Price.discount_price(price_code, additional_location_charge)
            log('Applying additional location charge')
            log("Charge: #{additional_location_charge}")
            log("Price code: #{price_code}")
            discount_price = Spree::Price.discount_price(price_code, additional_location_charge)
            log("Discounted Charge: #{discount_price}")
            log("After Run applied unit cost: #{unit_price}")
          end
        when 'rush'
          # No ranges
          rush_charge = product_upcharge[:value].to_f
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
end

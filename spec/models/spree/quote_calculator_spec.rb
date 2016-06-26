require 'rails_helper'

RSpec.describe Spree::Quote, type: :model do
  let(:quote) { FactoryGirl.create(:quote) }

  it 'should apply price discount' do
    discount = 0.50
    ('A'..'K').each do |letter|
      quote.unit_price = 100
      quote.apply_price_discount(letter)
      expect(((discount * 100) - quote.unit_price).abs).to be < 0.0001
      discount += 0.05
    end
  end

  it 'should apply EQP discount' do
    quote.unit_price = 100
    quote.apply_eqp
    expect(quote.unit_price).to eq 75.00
  end

  xit 'should apply a pms_color_match upcharge' do
    auction_data[:flags] = {
      pms_color_match: true,
      change_ink: false,
      no_under_over: false
    }
    auction_data[:supplier_upcharges] = [
      [1, 'pms_color_match', 'C', 50.00],
      [2, 'ink_change', 'C', 60.00],
      [3, 'no_under_over', 'C', 70.00]
    ]

    prebid.send(:apply_supplier_upcharges, auction_data)
    expect((100.3 - auction_data[:running_unit_price]).abs).to be < 0.0001
  end

  xit 'should apply a pms_color_match and change_ink upcharge' do
    auction_data[:flags] = {
      pms_color_match: true,
      change_ink: true,
      no_under_over: false
    }
    auction_data[:supplier_upcharges] = [
      [1, 'pms_color_match', 'C', 50.00],
      [2, 'ink_change', 'C', 60.00],
      [3, 'no_under_over', 'C', 70.00]
    ]

    prebid.send(:apply_supplier_upcharges, auction_data)
    expect((100.66 - auction_data[:running_unit_price]).abs).to be < 0.0001
  end

  xit 'should apply a pms_color_match, change_ink upcharge and no_under_over' do
    auction_data[:flags] = {
      pms_color_match: true,
      change_ink: true,
      no_under_over: true
    }
    auction_data[:supplier_upcharges] = [
      [1, 'pms_color_match', 'C', 50.00],
      [2, 'ink_change', 'C', 60.00],
      [3, 'no_under_over', 'C', 70.00]
    ]

    prebid.send(:apply_supplier_upcharges, auction_data)
    expect((101.08 - auction_data[:running_unit_price]).abs).to be < 0.0001
  end

  xit 'should not apply any supplier upcharges' do
    auction_data[:flags] = {
      pms_color_match: false,
      change_ink: false,
      no_under_over: false
    }
    auction_data[:supplier_upcharges] = [
      [1, 'pms_color_match', 'C', 50.00],
      [2, 'ink_change', 'C', 60.00],
      [3, 'no_under_over', 'C', 70.00]
    ]

    prebid.send(:apply_supplier_upcharges, auction_data)
    expect((100 - auction_data[:running_unit_price]).abs).to be < 0.0001
  end

  xit 'should apply product setup charge' do
    auction_data[:flags] = {
      pms_color_match: false,
      change_ink: false,
      no_under_over: false
    }
    auction_data[:supplier_upcharges] = [
      [1, 'pms_color_match', 'C', 50.00],
      [2, 'ink_change', 'C', 60.00],
      [3, 'no_under_over', 'C', 70.00]
    ]
    auction_data[:product_upcharges] = [
      [1, 'setup', 'Setup Test', 'C', 50.00, nil]
    ]

    prebid.send(:apply_product_upcharges, auction_data)
    expect((100.3 - auction_data[:running_unit_price]).abs).to be < 0.0001
  end

  xit 'should apply product rush charge' do
    auction_data[:flags] = {
      pms_color_match: false,
      change_ink: false,
      no_under_over: false
    }
    auction_data[:supplier_upcharges] = [
      [1, 'pms_color_match', 'C', 50.00],
      [2, 'ink_change', 'C', 60.00],
      [3, 'no_under_over', 'C', 70.00]
    ]
    auction_data[:product_upcharges] = [
      [1, 'rush', 'Rush Test', 'C', 100.00, nil]
    ]

    prebid.send(:apply_product_upcharges, auction_data)
    expect((100.6 - auction_data[:running_unit_price]).abs).to be < 0.0001
  end

  xit 'should apply additional location charge' do
    auction_data[:flags] = {
      pms_color_match: false,
      change_ink: false,
      no_under_over: false
    }
    auction_data[:num_locations] = 2
    auction_data[:num_colors] = 2
    auction_data[:supplier_upcharges] = [
      [1, 'pms_color_match', 'C', 50.00],
      [2, 'ink_change', 'C', 60.00],
      [3, 'no_under_over', 'C', 70.00]
    ]
    auction_data[:product_upcharges] = [
      [6, 'additional_location_run', 'additional_location_run', 'C', 1.10, '(0..49)'],
      [7, 'additional_location_run', 'additional_location_run', 'C', 1.20, '(50..99)'],
      [8, 'additional_location_run', 'additional_location_run', 'C', 1.30, '(100..149)'],
      [9, 'additional_location_run', 'additional_location_run', 'C', 1.40, '(150..199)']
    ]

    prebid.send(:apply_product_upcharges, auction_data)
    expect((100.78 - auction_data[:running_unit_price]).abs).to be < 0.0001
  end

  xit 'should apply second color charge' do
    auction_data[:flags] = {
      pms_color_match: false,
      change_ink: false,
      no_under_over: false
    }
    auction_data[:num_locations] = 2
    auction_data[:num_colors] = 2
    auction_data[:supplier_upcharges] = [
      [1, 'pms_color_match', 'C', 50.00],
      [2, 'ink_change', 'C', 60.00],
      [3, 'no_under_over', 'C', 70.00]
    ]
    auction_data[:product_upcharges] = [
      [6, 'second_color_run', 'second_color_run', 'C', 1.20, '(0..49)'],
      [7, 'second_color_run', 'second_color_run', 'C', 1.30, '(50..99)'],
      [8, 'second_color_run', 'second_color_run', 'C', 1.40, '(100..149)'],
      [9, 'second_color_run', 'second_color_run', 'C', 1.50, '(150..199)']
    ]

    prebid.send(:apply_product_upcharges, auction_data)
    expect((100.84 - auction_data[:running_unit_price]).abs).to be < 0.0001
  end

  xit 'should apply additional color charge' do
    auction_data[:flags] = {
      pms_color_match: false,
      change_ink: false,
      no_under_over: false
    }
    auction_data[:num_locations] = 2
    auction_data[:num_colors] = 2
    auction_data[:supplier_upcharges] = [
      [1, 'pms_color_match', 'C', 50.00],
      [2, 'ink_change', 'C', 60.00],
      [3, 'no_under_over', 'C', 70.00]
    ]
    auction_data[:product_upcharges] = [
      [6, 'additional_color_run', 'additional_color_run', 'C', 1.20, '(0..49)'],
      [7, 'additional_color_run', 'additional_color_run', 'C', 1.30, '(50..99)'],
      [8, 'additional_color_run', 'additional_color_run', 'C', 1.40, '(100..149)'],
      [9, 'additional_color_run', 'additional_color_run', 'C', 1.50, '(150..199)']
    ]

    prebid.send(:apply_product_upcharges, auction_data)
    expect((100.84 - auction_data[:running_unit_price]).abs).to be < 0.0001
  end

  xit 'should apply multiple color charge' do
    auction_data[:flags] = {
      pms_color_match: false,
      change_ink: false,
      no_under_over: false
    }
    auction_data[:num_locations] = 2
    auction_data[:num_colors] = 2
    auction_data[:supplier_upcharges] = [
      [1, 'pms_color_match', 'C', 50.00],
      [2, 'ink_change', 'C', 60.00],
      [3, 'no_under_over', 'C', 70.00]
    ]
    auction_data[:product_upcharges] = [
      [6, 'multiple_color_run', 'multiple_color_run', 'C', 1.33, '(0..49)'],
      [7, 'multiple_color_run', 'multiple_color_run', 'C', 1.44, '(50..99)'],
      [8, 'multiple_color_run', 'multiple_color_run', 'C', 1.55, '(100..149)'],
      [9, 'multiple_color_run', 'multiple_color_run', 'C', 1.66, '(150..199)']
    ]

    prebid.send(:apply_product_upcharges, auction_data)
    expect((100.93 - auction_data[:running_unit_price]).abs).to be < 0.0001
  end

  xit 'should apply multiple upcharges' do
    auction_data[:flags] = {
      pms_color_match: true,
      change_ink: false,
      no_under_over: false
    }
    auction_data[:quantity] = 151
    auction_data[:num_locations] = 2
    auction_data[:num_colors] = 2
    auction_data[:supplier_upcharges] = [
      [1, 'pms_color_match', 'C', 50.00],
      [2, 'ink_change', 'C', 60.00],
      [3, 'no_under_over', 'C', 70.00]
    ]
    auction_data[:product_upcharges] = [
      [1, 'setup', 'Setup Test', 'C', 50.00, nil],
      [1, 'rush', 'Rush Test', 'C', 50.00, nil],
      [6, 'multiple_color_run', 'multiple_color_run', 'C', 2.33, '(0..49)'],
      [7, 'multiple_color_run', 'multiple_color_run', 'C', 2.44, '(50..99)'],
      [8, 'multiple_color_run', 'multiple_color_run', 'C', 2.55, '(100..149)'],
      [9, 'multiple_color_run', 'multiple_color_run', 'C', 2.66, '(150..199)']
    ]

    prebid.send(:apply_product_upcharges, auction_data)
    expect((102.1920 - auction_data[:running_unit_price]).abs).to be < 0.0001
  end

  xit 'should process open ended range' do
    auction_data[:flags] = {
      pms_color_match: true,
      change_ink: false,
      no_under_over: false
    }
    auction_data[:quantity] = 151
    auction_data[:num_locations] = 2
    auction_data[:num_colors] = 2
    auction_data[:supplier_upcharges] = [
      [1, 'pms_color_match', 'C', 50.00],
      [2, 'ink_change', 'C', 60.00],
      [3, 'no_under_over', 'C', 70.00]
    ]
    auction_data[:product_upcharges] = [
      [1, 'setup', 'Setup Test', 'C', 50.00, nil],
      [1, 'rush', 'Rush Test', 'C', 50.00, nil],
      [6, 'multiple_color_run', 'multiple_color_run', 'C', 2.33, '(0..49)'],
      [7, 'multiple_color_run', 'multiple_color_run', 'C', 2.44, '(50..99)'],
      [8, 'multiple_color_run', 'multiple_color_run', 'C', 2.55, '(100..149)'],
      [9, 'multiple_color_run', 'multiple_color_run', 'C', 2.66, '(150+)']
    ]

    prebid.send(:apply_product_upcharges, auction_data)
    expect((100.5960 - auction_data[:running_unit_price]).abs).to be < 2
  end

  xit 'should provide fixed shipping' do
    auction_data[:carton] = FactoryGirl.build(:carton, originating_zip: '', fixed_price: 1.0)
    auction_data[:selected_shipping] = Spree::ShippingOption::OPTION[:ups_ground]
    prebid.send(:calculate_shipping, auction_data)
    expect(1.0 - auction_data[:shipping_cost]).to be < 0.0001
  end
end

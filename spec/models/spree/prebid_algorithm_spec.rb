require 'rails_helper'

RSpec.describe Spree::Prebid, type: :model do
  let(:auction) { FactoryGirl.create(:auction) }
  let(:prebid) { FactoryGirl.create(:prebid) }
  let(:auction_data) do
    {
      auction_id: auction.id,
      prebid_id: prebid.id,
      base_unit_price: 100,
      running_unit_price: 100,
      quantity: 100
    }
  end

  xit 'should call the prebid algorithm' do
    prebid.create_prebid(auction.id)
  end

  it 'should apply payment processing fee for non preferred supplier' do
    previous_running_unit_price = auction_data[:running_unit_price]
    prebid.send(:apply_processing_fee, auction, auction_data)
    expect(auction_data[:running_unit_price]).to be > previous_running_unit_price
  end

  it 'should not apply payment processing fee for preferred supplier' do
    previous_running_unit_price = auction_data[:running_unit_price]
    FactoryGirl.create(:auctions_user, auction: auction, user: prebid.seller)
    prebid.send(:apply_processing_fee, auction, auction_data)
    expect(auction_data[:running_unit_price]).to eq previous_running_unit_price
  end

  it 'should apply price discount' do
    discount = 0.50
    ('A'..'K').each do |letter|
      prebid.send(:apply_price_discount, auction_data, letter)
      expect(((discount * 100) - auction_data[:running_unit_price]).abs).to be < 0.0001
      discount += 0.05
    end
  end

  it 'should apply a pms_color_match upcharge' do
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

  it 'should apply a pms_color_match and change_ink upcharge' do
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

  it 'should apply a pms_color_match, change_ink upcharge and no_under_over' do
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

  it 'should not apply any supplier upcharges' do
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

  it 'should apply product setup charge' do
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

  it 'should apply product rush charge' do
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

  it 'should apply additional location charge' do
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

  it 'should apply second color charge' do
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

  it 'should apply additional color charge' do
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

  it 'should apply multiple color charge' do
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

  it 'should apply multiple upcharges' do
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
    expect((101.9933 - auction_data[:running_unit_price]).abs).to be < 0.0001
  end

  it 'should process open ended range' do
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
    expect((100.3973 - auction_data[:running_unit_price]).abs).to be < 0.0001
  end
end

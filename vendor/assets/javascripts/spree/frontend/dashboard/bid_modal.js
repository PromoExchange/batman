$(function() {
  var key = $('#seller-live-auction-table').attr('data-key');

  function get_auction(auction_id) {
    var auction_url = '/api/auctions/' + auction_id;

    $.ajax({
      type: 'GET',
      url: auction_url,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        $('.modal-body #quantity-requested').text(data.quantity);
        $('.modal-body #payment-method').text(data.payment_method);
        var num_bids = data.bids.length;
        var total_low_bid = 'no bids';
        var per_low_bid = 'no bids';

        if (num_bids > 0) {
          low_bid = parseFloat(data.bids[0].bid);
          total_low_bid = accounting.formatMoney(low_bid)
          per_low_bid = accounting.formatMoney(low_bid / data.quantity)
        }
        
        $('.modal-body #lowest-per-unit-price').text(per_low_bid);
        $('.modal-body #lowest-total-price').text(total_low_bid);
        $('.modal-body #per-unit-price').val(data.product_unit_price);
        calc_prices('per-unit-price');
        stop_download();
      }
    });
  }

  function calc_prices(anchor_field) {
    var per_unit_price = 0;
    var total_price = 0;
    var per_unit_price_shown = 0;
    var total_price_shown = 0;
    var quantity = parseFloat($('.modal-body #quantity-requested').text());

    var processing_markup = 0.015;
    if ($('.modal-body #payment-method').text() === 'Credit Card') {
      processing_markup = 0.029;
    }

    processing_flat_fee = 0.30;

    var px_markup = 0.0899;
    var total_markup = (processing_markup + px_markup);
    var flash_fields = [];

    if (anchor_field === 'per-unit-price') {
      per_unit_price = parseFloat($('.modal-body #per-unit-price').val().replace('$', ''));
      total_price = per_unit_price * quantity;
      per_unit_price_shown = per_unit_price / (1 - total_markup);
      total_price_shown = per_unit_price_shown.toFixed(2) * quantity;
      flash_fields.push(
        '.modal-body #total-price',
        '.modal-body #per-unit-price-shown',
        '.modal-body #total-price-shown'
      );
    } else if (anchor_field === 'total-price') {
      total_price = parseFloat($('.modal-body #total-price').val().replace('$', ''));
      per_unit_price = total_price / quantity;
      per_unit_price_shown = per_unit_price / (1 - total_markup);
      total_price_shown = per_unit_price_shown.toFixed(2) * quantity;
      flash_fields.push(
        '.modal-body #per-unit-price',
        '.modal-body #per-unit-price-shown',
        '.modal-body #total-price-shown'
      );
    } else if (anchor_field === 'per-unit-price-shown') {
      per_unit_price_shown = parseFloat($('.modal-body #per-unit-price-shown').val().replace('$', ''));
      total_price_shown = per_unit_price_shown * quantity;
      per_unit_price = per_unit_price_shown * (1 - total_markup);
      total_price = per_unit_price.toFixed(2) * quantity;
      flash_fields.push(
        '.modal-body #per-unit-price',
        '.modal-body #total-price',
        '.modal-body #total-price-shown'
      );
    } else if (anchor_field === 'total-price-shown') {
      total_price_shown = parseFloat($('.modal-body #total-price-shown').val().replace('$', ''));
      per_unit_price_shown = total_price_shown / quantity;
      per_unit_price = per_unit_price_shown * (1 - total_markup);
      total_price = per_unit_price.toFixed(2) * quantity;
      flash_fields.push(
        '.modal-body #per-unit-price',
        '.modal-body #total-price',
        '.modal-body #per-unit-price-shown'
      );
    }
    $('.modal-body #per-unit-price').val(accounting.formatMoney(per_unit_price));
    $('.modal-body #total-price').val(accounting.formatMoney(total_price));
    $('.modal-body #per-unit-price-shown').val(accounting.formatMoney(per_unit_price_shown));
    $('.modal-body #total-price-shown').val(accounting.formatMoney(total_price_shown));
    var s = flash_fields.join(',');
    $(s).stop().css("background-color", "#FFFF9C")
      .animate({
        backgroundColor: "#FFFFFF"
      }, 500);
  }

  function start_download(data) {
    $('.fa-spinner').show();
    $('.modal-footer button').prop('disabled', true);
    $('input.bid-edit').prop('disabled', true);
  }

  function stop_download(data) {
    $('.fa-spinner').hide();
    $('.modal-footer button').prop('disabled', false);
    $('input.bid-edit').prop('disabled', false);
  }

  $('.modal-body #per-unit-price').change(function() {
    calc_prices('per-unit-price');
  });

  $('.modal-body #total-price').change(function() {
    calc_prices('total-price');
  });

  $('.modal-body #per-unit-price-shown').change(function() {
    calc_prices('per-unit-price-shown');
  });

  $('.modal-body #total-price-shown').change(function() {
    calc_prices('total-price-shown');
  });

  $('#place-bid-submit').click(function(e) {
    e.preventDefault();
    var auction_id = $('#auction-id').val();
    var seller_id = $('#seller-id').val();
    var bid = $('#total-price-shown').val().replace(/[$ ,]/gi,'');

    if (bid.split('.')[0].length > 8) {
      alert('Total price shown value must be less than 9 digit i.e. 12345678.12');
      return false
    }

    if (bid.split('.')[0] == 0) {
      alert('Total price shown must be greater than $0.00');
      return false
    }

    var bid_message = {
      seller_id: parseInt(seller_id, 10),
      auction_id: parseInt(auction_id, 10),
      per_unit_bid: parseFloat(bid)
    };
    $.ajax({
      type: 'POST',
      contentType: "application/json",
      data: JSON.stringify(bid_message),
      url: '/api/bids',
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        alert(data.message);
        $('#seller-live-auction-tab').trigger('click');
      },
      error: function(data) {
        console.log(data);
      }
    });
  });

  $('tbody').on('click', 'button.open-bid', function(e) {
    start_download();
    var auction_id = $(this).data('id');
    $('#auction-id').val(auction_id);
    get_auction(auction_id);
  });
});

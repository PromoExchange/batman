$(function(){
  var key = $("#seller-live-auction-table").attr("data-key");

  function get_auction(auction_id){
    var auction_url = '/api/auctions/' + auction_id;

    $.ajax({
      type: 'GET',
      data:{
        format: 'json'
      },
      url: auction_url,
      headers:{
        'X-Spree-Token': key
      },
      success: function(data){
        $('.modal-body #quantity-requested').text(data.quantity);
        var low_bid = data.lowest_bid;
        if ( low_bid == null){
          $('.modal-body #lowest-per-unit-price').text('no bids');
          $('.modal-body #lowest-total-price').text('no bids');
        }else{
          $('.modal-body #lowest-per-unit-price').text(low_bid / data.quantity);
          $('.modal-body #lowest-total-price').text(low_bid);
        }
        $('.modal-body #per-unit-price').val(data.product_unit_price);
        calc_prices('per-unit-price');
        stop_download();
      }
    });
  }

  function calc_prices(anchor_field)
  {
    var per_unit_price = 0;
    var total_price = 0;
    var per_unit_price_shown = 0;
    var total_price_shown = 0;
    var quantity = parseFloat($('.modal-body #quantity-requested').text());
    // TODO: Get these from config/database
    var seller_markup = 0.15;
    var px_markup = 0.0299;
    var total_markup = (seller_markup + px_markup);

    if (anchor_field == 'per-unit-price'){
      per_unit_price = parseFloat($('.modal-body #per-unit-price').val());
      total_price = per_unit_price * quantity;
      per_unit_price_show = (per_unit_price / (1 - total_markup));
      total_price_shown = per_unit_price_show * quantity;
    } else if (anchor_field == 'total-price'){
      total_price = parseFloat($('.modal-body #total-price').val());
      per_unit_price = total_price / quantity;
      per_unit_price_show = (per_unit_price / (1 - total_markup));
      total_price_shown = per_unit_price_show * quantity;
    } else if (anchor_field == 'per-unit-price-shown'){
      per_unit_price_show = parseFloat($('.modal-body #per-unit-price-shown').val());
      total_price_shown = per_unit_price_show * quantity;
      per_unit_price = (per_unit_price_show / (1 + total_markup));
      total_price = per_unit_price * quantity;
    } else if (anchor_field == 'total-price-shown'){
      total_price_shown = parseFloat($('.modal-body #total-price-shown').val());
      per_unit_price_show = total_price_shown / quantity;
      per_unit_price = (per_unit_price_show / (1 + total_markup));
      total_price = per_unit_price * quantity;
    }
    $('.modal-body #per-unit-price').val(+per_unit_price.toFixed(2));
    $('.modal-body #total-price').val(+total_price.toFixed(2));
    $('.modal-body #per-unit-price-shown').val(+per_unit_price_show.toFixed(2));
    $('.modal-body #total-price-shown').val(+total_price_shown.toFixed(2));
  }

  function start_download(data){
    $('.modal-footer button').prop('disabled', true);
    $('.fa-spinner').show();
    $('.modal-body #per-unit-price').prop('disabled', true);
    $('.modal-body #total-price').prop('disabled', true);
    $('.modal-body #per-unit-price-shown').prop('disabled', true);
    $('.modal-body #total-price-shown').prop('disabled', true);
  }

  function stop_download(data){
    $('.modal-footer button').prop('disabled', false);
    $('.fa-spinner').hide();
    $('.modal-body #per-unit-price').prop('disabled', false);
    $('.modal-body #total-price').prop('disabled', false);
    $('.modal-body #per-unit-price-shown').prop('disabled', false);
    $('.modal-body #total-price-shown').prop('disabled', false);
  }

  function post_bid() {

  }

  $('.modal-body #per-unit-price').change(function(){
    calc_prices('per-unit-price')
  });

  $('.modal-body #total-price').change(function(){
    calc_prices('total-price')
  });

  $('.modal-body #per-unit-price-shown').change(function(){
    calc_prices('per-unit-price-shown')
  });

  $('.modal-body #total-price-shown').change(function(){
    calc_prices('total-price-shown')
  });

  $('#place-bid-submit').click(function(){
    alert('Submit me');
    event.preventDefault();
  });

  $('tbody').on('click','button.open-bid',function(e){
    start_download();
    var auction_id = $(this).data('id');
    get_auction(auction_id);
  });
});

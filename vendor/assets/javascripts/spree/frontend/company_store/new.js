$(function(){
  // TODO: Merge with auction/new_auction.js
  var delay = (function(){
    var timer = 0;
    return function(callback, ms){
      clearTimeout (timer);
      timer = setTimeout(callback, ms);
      };
  })();

  function recalc_price() {
    var actual = 0;
    var min = 0;

    if($('#auction-size .product-size').length) {
      $('#auction-size .product-size').each(function() {
       actual += parseInt('0'+ $(this).val());
       min = parseInt($("#auction-size").attr('min-quantity'));
      });
    } else {
      var e = $(".cs-quantity");
      min = parseInt(e.attr('min'));
      actual = parseInt(e.val());
    }

    $(".cs-active-price").hide();

    if (actual >= min) {
      $("#price-spin").show();
      var auction_clone_id = $("#auction_clone_id").val();
      var api_key = $('#new-auction').attr('data-key');
      var params = {
        auction: {
          quantity: actual,
          ship_to_zip: $('#auction_ship_to_zip').val()
        }
      };
      var url = '/api/auctions/'+auction_clone_id+'/best_price';
      $.ajax({
        type: 'GET',
        contentType: "application/json",
        url: url,
        data: params,
        headers: {
          'X-Spree-Token': api_key
        },
        success: function(data) {
          var money_text = accounting.formatMoney((parseFloat(data.best_price)));
          $(".cs-active-price").text(money_text);
          $(".cs-active-price").show();
          $("#price-spin").hide();
          $('.cs-purchase-submit').prop('disabled', false);
        },
        error: function(data) {
          $(".cs-active-price").text('No Price Found');
          $(".cs-active-price").show();
          $("#price-spin").hide();
        }
      });
    }
  }

  $(".cs-quantity").keyup(function() {
    $('.cs-purchase-submit').prop('disabled', true);
    if($('#address_drop').val() === '') {
      return;
    }
    delay(function(){recalc_price();},500);
  });

  $('#auction_ship_to_zip').change(function() {
    set_address_id();
    recalc_price();
  });

  $(document).ready(function() {
    set_address_id();
  });

  function set_address_id() {
    var address_id = $('#auction_ship_to_zip option:selected').attr('data-id');
    $('#auction_address_id').val(address_id);
  }
});

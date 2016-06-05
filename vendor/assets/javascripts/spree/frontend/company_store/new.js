$(function(){
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
      min = parseInt($("#auction-size").attr('min-quantity'));
      $('#auction-size .product-size').each(function() {
        actual += parseInt('0'+ $(this).val());
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
          ship_to_zip: $('#auction_ship_to_zip').val(),
          shipping_option: $('#shipping_option').val()
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
          $('#ship_date').text(
            moment(new Date())
            .add(data.delivery_days, 'days')
            .format('MMMM Do YYYY')
          );
          var shipping_option_control = $('#shipping_option');
          shipping_option_control.empty();
          debugger;
          $.each(data.shipping_options, function(index, option){
            var new_option = $('<option>',{value: option.shipping_option, delta: option.delta})
              .text(option.name + accounting.formatMoney((parseFloat(option.delta))));
            shipping_option_control.append(new_option);
          });

          $(".cs-active-price").text(money_text);
          $("#price-spin").hide();
          $('.cs-purchase-submit').prop('disabled', false);
          $(".cs-active-price").show();
        },
        error: function(data) {
          $(".cs-active-price").text('No Price Found');
          $("#price-spin").hide();
          $(".cs-active-price").show();
        }
      });
    }
  }

  // TODO: Switch style in new auction view
  $(".cs-quantity").keyup(function() {
    if( $("#auction_clone_id").val() === "") return;
    $('.cs-purchase-submit').prop('disabled', true);
    $('#ship_date').text('--');
    if($('#address_drop').val() === '') {
      return;
    }
    delay(function(){recalc_price();},500);
  });

  $('#auction_ship_to_zip').change(function() {
    set_address_id();
    $('.cs-purchase-submit').prop('disabled', true);
    $('#ship_date').text('--');
    recalc_price();
  });

  $('#shipping_option').change(function() {
    recalc_price();
  });

  $('#need_it_sooner').click(function() {
    $('#need_it_sooner').hide();
    $('#shipping_option_group').show();
  });

  $('#auction-size .product-size').change(function() {
    $('.cs-purchase-submit').prop('disabled', true);
    $('#ship_date').text('--');
    var sum = 0;
    $('#auction-size .product-size').each(function() {
      sum+= parseInt('0'+ $(this).val());
    });
    $('.total-qty span:last').text(sum);
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

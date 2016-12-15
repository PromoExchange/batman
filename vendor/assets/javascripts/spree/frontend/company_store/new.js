$(function() {
  var delay = (function() {
    var timer = 0;
    return function(callback, ms) {
      clearTimeout(timer);
      timer = setTimeout(callback, ms);
    };
  })();

  function get_quantity() {
    var actual = 0;
    var min = 0;

    if($('#purchase-size .product-size').length) {
      min = parseInt($("#purchase-size").attr('min-quantity'));
      $('#purchase-size .product-size').each(function() {
        actual += parseInt('0'+ $(this).val());
      });
    } else {
      var e = $(".cs-quantity");
      min = parseInt(e.attr('min'));
      actual = parseInt(e.val());
    }

    return {
      min: min,
      actual: actual
    };
  }

  function recalc_price() {
    var actual = 0;
    var min = 0;

    var quantities = get_quantity();
    if ($('#purchase_company_store_slug').val() !== 'gooten') {
      min = quantities.min;
    }
    actual = quantities.actual;
    $(".cs-active-price").hide();

    if (actual >= min) {
      $("#price-spin").show();
      var api_key = $('#new-purchase').attr('data-key');
      var product_id = $('#purchase_product_id').val();
      var selected_shipping_option = $('#purchase_shipping_option').val();

      if ($('#purchase_company_store_slug').val() !== 'gooten') {
        var address_id = $('#purchase_ship_to_zip option:selected').attr('data-id');
        var params = {
          purchase: {
            quantity: actual,
            shipping_address: address_id
            shipping_option: selected_shipping_option
          }
        };
      } else {
        company = $('#purchase_company').val();
        address1 = $('#purchase_address1').val();
        address2 = $('#purchase_address2').val();
        city = $('#purchase_city').val();
        state_id = $('#purchase_state_id').val();
        zip_code = $('#purchase_zip_code').val();

        var params = {
          purchase: {
            quantity: actual,
            address: {
              company: company,
              address1: address1,
              address2: address2,
              city: city,
              state_id: state_id,
              zip_code: zip_code
            },
            shipping_option: selected_shipping_option,
            pms_colors: '123,456,789' # TODO: Make this dynamic
          }
        };
      }

      $.ajax({
        type: 'GET',
        contentType: "application/json",
        url: '/api/products/' + product_id + '/best_price',
        data: params,
        headers: {
          'X-Spree-Token': api_key
        },
        success: function(data) {
          if (typeof data.error_message !== typeof undefined ? true : false) {
            $(".cs-active-price").text(data.error_message);
            $("#price-spin").hide();
            $('.cs-purchase-submit').prop('disabled', false);
            $(".cs-active-price").show();
            return;
          }

          var money_text = accounting.formatMoney((parseFloat(data.best_price)));
          $('#ship_date').text(
            moment(new Date())
            .add(data.delivery_days, 'days')
            .format('MMMM Do YYYY')
          );
          var number_options = 0;
          var shipping_option_control = $('#purchase_shipping_option');
          if(typeof selected_shipping_option == 'undefined') {
            selected_shipping_option = data.shipping_option;
          }
          shipping_option_control.empty();
          sorted_options = data.shipping_options.sort(function(a, b) { return a.shipping_option - b.shipping_option });
          $.each(sorted_options, function(index, option) {
            var sign = '+';
            var option_money_text = accounting.formatMoney((parseFloat(option.delta)));
            if (option.delta < 0.01) {
              sign = '';
              option_money_text = '';
            }
            var option_text = option.name + ' ' + sign + option_money_text;
            selected_value = false;
            if (option.shipping_option == selected_shipping_option) {
              selected_value = true;
            }
            var new_option = $('<option>', {
                value: option.shipping_option,
                delta: option.delta,
                name: option.name,
                delivery_date: option.delivery_date,
                selected: selected_value
            }).text(option_text);
            shipping_option_control.append(new_option);
            number_options++;
          });

          if(number_options > 0 && !$('#need_it_sooner').is(":visible") ) {
            $('#need_it_sooner').show();
          }

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

  $(".cs-quantity").keyup(function() {
    $('.cs-purchase-submit').prop('disabled', true);
    $('#ship_date').text('--');
    if($('#address_drop').val() === '') {
      return;
    }
    delay(function() {
      recalc_price();
    }, 500);
  });

  $('#purchase_ship_to_zip').change(function() {
    set_address_id();
    $('.cs-purchase-submit').prop('disabled', true);
    $('#ship_date').text('--');
    recalc_price();
  });

  $('#purchase_shipping_option').change(function() {
    var selected_shipping_option = $('#purchase_shipping_option option:selected');
    var delivery_date = selected_shipping_option.attr('delivery_date');
    var delta = parseFloat(selected_shipping_option.attr('delta'));
    var old_price = accounting.unformat($(".cs-active-price").text());
    var new_price = old_price + delta;

    $('#ship_date').text(
      moment(delivery_date).format('MMMM Do YYYY');
    );

    var money_text = accounting.formatMoney(new_price);
    $(".cs-active-price").text(money_text)

    $('#purchase_shipping_option > option').each(function() {
      var option = $(this);
      var old_delta = parseFloat(option.attr('delta'));
      var new_delta = (old_price + old_delta) - new_price;
      option.attr('delta', new_delta);

      var sign = '+';
      var option_money_text = accounting.formatMoney((parseFloat(new_delta)));
      if (new_delta < 0) {
        sign = '-';
        option_money_text = accounting.formatMoney((parseFloat(Math.abs(new_delta))));
      } else if (new_delta == 0) {
        sign = '';
        option_money_text = '';
      }

      var option_text = option.attr('name') + ' ' + sign + option_money_text;
      $(this).text(option_text);
    });
  });

  $('#need_it_sooner').click(function() {
    $('#need_it_sooner').hide();
    $('#shipping_option_group').show();
  });

  $('#purchase-size .product-size').change(function() {
    $('.cs-purchase-submit').prop('disabled', true);
    $('#ship_date').text('--');
    var sum = 0;
    $('#purchase-size .product-size').each(function() {
      sum += parseInt('0'+ $(this).val());
    });
    $('.total-qty span:last').text(sum);
    recalc_price();
  });

  $(document).ready(function() {
    set_address_id();
    $('#need_it_sooner').hide();
    $(".cs-quantity").val('');
    $('#purchase-size .product-size').each(function() {
      $(this).val('');
    });
  });

  function set_address_id() {
    var address_id = $('#purchase_ship_to_zip option:selected').attr('data-id');
    $('#purchase_address_id').val(address_id);
  }
});

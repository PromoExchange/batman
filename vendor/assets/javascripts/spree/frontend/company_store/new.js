$(function() {
  var delay = (function(){
    var timer = 0;
    return function(callback, ms) {
      clearTimeout (timer);
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

    return { min: min, actual: actual };
  }

  function recalc_price() {
    if (!addressFilled() && ($('#purchase_ship_to_zip').val() === '' || $('#purchase_ship_to_zip').val() === undefined)) {
      return;
    }

    var actual = 0;
    var min = 1;

    var quantities = get_quantity();
    if ($('#purchase_company_store_slug').val() != 'gooten') {
       min = quantities.min;
    }
    actual = quantities.actual;
    if (actual === 0) {
      return;
    }
    $(".cs-active-price").hide();

    if (actual >= min) {
      $("#price-spin").show();
      var selected_shipping_option = $('#purchase_shipping_option').val();
      var address_id = $('#purchase_ship_to_zip option:selected').attr('data-id');

      if ($('#purchase_company_store_slug').val() != 'gooten') {
        var params = {
          purchase: {
            quantity: actual,
            shipping_address: address_id,
            shipping_option: selected_shipping_option
          }
        };
      } else {
        var params = {
          purchase: {
            quantity: actual,
            shipping_address: {
              company: $('#purchase_address_company').val(),
              address1: $('#purchase_address_address1').val(),
              address2: $('#purchase_address_address2').val(),
              city: $('#purchase_address_city').val(),
              state_id: $('#purchase_address_state').val(),
              zipcode: $('#purchase_address_zipcode').val()
            },
            shipping_option: selected_shipping_option,
            custom_pms_colors: '123,456' // TODO: Make this dynamic
          }
        };
      }

      $.ajax({
        type: 'POST',
        url: '/api/products/' + $('#purchase_product_id').val() + '/best_price',
        data: params,
        headers: {
          'X-Spree-Token': $('#new-purchase').attr('data-key')
        },
        success: function(data) {
          if (typeof data.error_message !== typeof undefined ? true : false) {
            $(".cs-active-price").text(data.error_message);
            $("#price-spin").hide();
            $('.cs-purchase-submit').prop('disabled', false);
            $(".cs-active-price").show();
            return;
          }

          if ($('#purchase_company_store_slug').val() == 'gooten') {
            $('#purchase_address_id').val(data.shipping_address_id);
          }

          var money_text = accounting.formatMoney((parseFloat(data.best_price)));
          $('#ship_date').text(moment(new Date()).add(data.delivery_days, 'days').format('MMMM Do YYYY'));
          var number_options = 0;
          var shipping_option_control = $('#purchase_shipping_option');
          if (typeof selected_shipping_option == 'undefined') {
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
            } else {
              option_text = option_text + ', Estimated delivery: ' + moment(option.delivery_date).format(' MMMM Do YYYY');
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

          if (number_options > 0 && !$('#need_it_sooner').is(":visible")) {
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

  function addressFilled() {
    var company = $('#purchase_address_company').val()
    var address1 = $('#purchase_address_address1').val()
    var city = $('#purchase_address_city').val()
    var state_id = $('#purchase_address_state').val()
    var zipcode = $('#purchase_address_zipcode').val()
    if (!company || !address1 || !city || !state_id || !zipcode) {
      return false;
    }

    return company.length > 0 && address1.length > 0 && city.length > 0 && state_id.length > 0 && zipcode.length > 0;
  }

  function addressChanged() {
    if (!addressFilled()) {
      return;
    }
    var sum = 0;

    $('.cs-purchase-submit').prop('disabled', true);
    $('#ship_date').text('--');
    $('#purchase-size .product-size').each(function() { sum += parseInt('0'+ $(this).val()) });
    $('.total-qty span:last').text(sum);

    recalc_price();
  }

  $("#purchase_address_company").change(addressChanged);
  $("#purchase_address_address1").change(addressChanged);
  $("#purchase_address_address2").change(addressChanged);
  $("#purchase_address_city").change(addressChanged);
  $("#purchase_address_state").change(addressChanged);
  $("#purchase_address_zipcode").change(addressChanged);

  $(".cs-quantity").keyup(function() {
    $('.cs-purchase-submit').prop('disabled', true);
    $('#ship_date').text('--');
    if ($('#address_drop').val() === '') {
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

  $('#purchase_quality_option').change(function() {
    var selected_quality_option = $('#purchase_quality_option option:selected');
    $('#purchase_product_id').val(selected_quality_option.attr('product-id'));
    var images = JSON.parse(selected_quality_option.attr('images'));
    $('.main-product-image').attr('src', images[0]['large_src']);
    var small_images_div = $('.small-images');
    small_images_div.empty();

    $.each(images, function( index, value ){
      small_images_div.append(
        $('<img class="secondary-product-image" src="http://placehold.it/100x100" alt="alt-text">')
          .attr('src', value['small_src'])
          .attr('alt', value['alt'])
      );
    });
    recalc_price();
  });

  $('#purchase_shipping_option').change(function() {
    var selected_shipping_option = $('#purchase_shipping_option option:selected');
    var delivery_date = selected_shipping_option.attr('delivery_date');
    var delta = parseFloat(selected_shipping_option.attr('delta'));
    var old_price = accounting.unformat($(".cs-active-price").text());
    var new_price = old_price + delta;

    $('#ship_date').text(moment(delivery_date).format('MMMM Do YYYY'));

    var money_text = accounting.formatMoney(new_price);
    $(".cs-active-price").text(money_text);

    $('#purchase_shipping_option > option').each(function() {
      var option = $(this);
      var old_delta = parseFloat(option.attr('delta'));
      var new_delta = (old_price + old_delta) - new_price;
      option.attr('delta', new_delta);

      var sign = '+';
      var option_money_text = accounting.formatMoney((parseFloat(new_delta)));
      var option_date_text = ', Estimated delivery: ' + moment(option.attr('delivery_date')).format(' MMMM Do YYYY');
      if (new_delta < 0) {
        sign = '-';
        option_money_text = accounting.formatMoney((parseFloat(Math.abs(new_delta))));
      } else if (new_delta == 0) {
        sign = '';
        option_money_text = '';
        option_date_text = '';
      }

      var option_text = option.attr('name') + ' ' + sign + option_money_text + option_date_text;
      $(this).text(option_text);
    });
  });

  $('#need_it_sooner').click(function() {
    $('#need_it_sooner').hide();
    $('#shipping_option_group').show();
  });

  $('#purchase-size .product-size').change(function() {
    var sum = 0;

    $('.cs-purchase-submit').prop('disabled', true);
    $('#ship_date').text('--');
    $('#purchase-size .product-size').each(function() { sum += parseInt('0'+ $(this).val()) });
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

$(function() {
  $(document).ready(function() {
    $('[data-toggle="tooltip"]').tooltip();
    $('[data-toggle="popover"]').popover();
    set_address_id();
    set_quality_tooltip();
    $('#need_it_sooner').hide();
    $(".cs-quantity").val('');
    $('#purchase-size .product-size').each(function() {
      $(this).val('');
    });
    if($('#purchase_company_store_type').val() === 'gooten') {
      // TODO: Place inside bounding CS div and drive with css
      $('.gooten-element').css({
        'margin-left': '20px',
        'margin-right': '20px'
      });
      $('.calculated').hide().css({'margin-left': '20px'});
      $('.gooten-element').hide();
      $('#breadcrumb-element').show();
      $('#quality-element').show();
      $('#left-panel').hide();
      $('#right-panel').removeClass('col-md-6');
      $('#right-panel').addClass('col-md-6 col-md-offset-3');
      $('.cs-purchase-submit').hide();
      $('#cs-container').css({
        'margin': '0 auto',
        'width':  '100%'
      });
    }
  });

  $('.logo-upload').change(function() {
    readURL(this);
  });

  $('button.question-page').click(function(crumb) {
    crumb.preventDefault();

    var previous = ($(this).attr("id") === 'previous-button');

    var current_slug = $("#breadcrumb-element").data('crumb');
    var next_slug = 'logo';

    switch(current_slug) {
      case 'color':
        next_slug = ( previous === true ? 'quantity' : 'logo' );
        break;
      case 'logo':
        next_slug = ( previous === true ? 'color' : 'address' );
        if ( previous !== true ) {
          $("#breadcrumb-element").data('address-seen', 'true');
          $('#next-button').html('Purchase');
          $('#previous-button').css({'margin-left': '30px'});
          recalc_price();
        } else {
          $('#next-button').html('Next');
          $('#previous-button').css({'padding-left': '0px'});
        }
        break;
      case 'quantity':
        next_slug = ( previous === true ? 'quality' : 'color' );
        break;
      case 'address':
        if( previous === false ) {
          if( $('.cs-active-price').is(':visible') ) {
            $('#new_purchase').submit();
            return;
          }
        }
        $('.cs-wrapper').css({'margin': '0 auto -60px'});
        next_slug = 'logo';
        $('#next-button').html('Next').removeClass('btn-primary');
        $('#previous-button').css({'margin-left': '0px'});
        break;
      case 'quality':
        if (previous === true) return;
        next_slug = 'quantity';
        break;
    }

    var next_disabled = false;
    switch(next_slug) {
      case 'quantity':
        next_disabled = !(get_quantity().actual > 0);
        break;
      case 'address':
        next_disabled = !addressFilled();
        break;
      case 'logo':
        next_disabled = !($("#breadcrumb-element").data('logod') === true );
        break;
    }
    $('#next-button').prop('disabled', next_disabled);

    $('ul.breadcrumb li.active').removeClass('active');
    $('ul.breadcrumb li').each(function(_i, c2) {
      var this_crumb = $(c2).children('div').data('crumb');
      if( this_crumb === current_slug ) {
        $(c2).addClass('completed');
      }
      if( this_crumb === next_slug) {
        $(c2).removeClass('completed');
        $(c2).addClass('active');
        return false;
      }
    });
    $('.gooten-element').hide();
    $('#' + next_slug + '-element').show();
    $("#breadcrumb-element").data('crumb',next_slug);
  });

  function readURL(input) {
    if (input.files && input.files[0]) {
      var reader = new FileReader();
      $("#breadcrumb-element").data('logod',true);
      reader.onload = function(e) {
        $('.logo-to-upload').attr('src', e.target.result).removeClass('hidden');
        $('#next-button').prop('disabled', false);
        $('#summary-element').removeClass('sticky-bottom');
      }
      reader.readAsDataURL(input.files[0]);
    }
  }

  var delay = (function(){
    var timer = 0;
    return function(callback, ms) {
      clearTimeout (timer);
      timer = setTimeout(callback, ms);
    };
  })();

  function set_summary() {
    var main_image = $('.main-product-image').first();
    var summary_image = $('.summary-product-image').first();
    $.each(["src","alt"], function(_i, s){
      summary_image.attr(s, main_image.attr(s));
    });

    var quantity = get_quantity();
    var bounding_line = $("#summary-quantity").closest("li");
    if( quantity.actual > 0 ) {
      $("#summary-quantity").text(get_quantity().display);
      bounding_line.show();
    } else {
      bounding_line.hide();
    }

    bounding_line = $("#summary-address").closest("li");
    if(addressFilled()) {
      var address_display = '<span>';
      var seperator = ', ';
      $.each(['company', 'address1', 'address2', 'city', 'state','zipcode'], function(_i, s){
        if(s === 'zipcode') {
          seperator = '';
        }
        if(s === 'state') {
          address_display += $('#purchase_address_state option:selected').text() + seperator;
        } else {
          address_line = $('#purchase_address_'+s).val();
          if(address_line) {
            address_display += address_line + seperator;
          }
        }
      });
      if(address_display != "<span>") {
        address_display += "</span>";
        $("#summary-address").html(address_display);
      }
      bounding_line.show();
    } else {
      bounding_line.hide();
    }

    $("#summary-quality").text($('#purchase_quality_option option:selected').text());
  }

  function get_quantity() {
    var actual = 0;
    var min = 0;
    var display = '';

    if($('#purchase-size .product-size').length) {
      min = parseInt($("#purchase-size").attr('min-quantity'));
      $('#purchase-size .product-size').each(function(index) {
        quantity_val = parseInt('0'+ $(this).val());
        if( quantity_val > 0 ) {
          actual += quantity_val;
          display += ['S','M','L','XL','2XL'][index];
          display += ':' + quantity_val.toString() + ' ';
        }
      });
    } else {
      var e = $(".cs-quantity");
      min = parseInt(e.attr('min'));
      actual = parseInt(e.val());
      display = actual.toString();
    }

    return { min: min, actual: actual, display: display};
  }

  function recalc_price() {
    if( $('#purchase_company_store_type').val() === 'gooten' ) {
      if( $("#breadcrumb-element").data('address-seen') !== 'true' ) return;
    }

    set_summary();
    if (!addressFilled() && ($('#purchase_ship_to_zip').val() === '' || $('#purchase_ship_to_zip').val() === undefined)) {
      return;
    }

    var actual = 0;
    var min = 1;

    var quantities = get_quantity();
    if ($('#purchase_company_store_type').val() != 'gooten') {
      min = quantities.min;
    }
    actual = quantities.actual;
    if (actual === 0) {
      return;
    }
    $(".cs-active-price").hide();
    $("#breakout_question").hide();

    if (actual >= min) {
      $("#price-spin").show();
      var selected_shipping_option = $('#purchase_shipping_option').val();
      var address_id = $('#purchase_ship_to_zip option:selected').attr('data-id');

      if ($('#purchase_company_store_type').val() == 'gooten') {
        var params = {
          purchase: {
            quantity: actual,
            shipping_address: address_id,
            shipping_option: selected_shipping_option
          }
        };
        $(".calculated").show();
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
            custom_pms_colors: null // TODO: Make this dynamic
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
            $("#breakout_question").show();
            return;
          }

          if ($('#purchase_company_store_slug').val() == 'gooten') {
            $('#purchase_address_id').val(data.shipping_address_id);
          }

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
              shipping_cost: accounting.formatMoney(option.shipping_cost),
              base_cost: accounting.formatMoney(option.total_cost - option.shipping_cost),
              delivery_date: option.delivery_date,
              selected: selected_value
            }).text(option_text);
            shipping_option_control.append(new_option);
            number_options++;
          });

          if (number_options > 0 && !$('#shipping_option_group').is(":visible")) {
            $('#need_it_sooner').show();
          }

          var best_price = parseFloat(data.best_price);
          var shipping_cost = parseFloat(data.shipping_cost);

          $(".cs-active-price")
            .text(accounting.formatMoney(best_price))
            .attr('base_cost', accounting.formatMoney(best_price - shipping_cost))
            .attr('shipping_cost', accounting.formatMoney(shipping_cost));

          $("#price-spin").hide();
          $('.cs-purchase-submit').prop('disabled', false);
          $(".cs-active-price").show();
          $("#breakout_question").show();
          $('#summary-element').removeClass('sticky-bottom');
        },
        error: function(data) {
          $(".cs-active-price").text('No Price Found');
          $("#price-spin").hide();
          $(".cs-active-price").show();
        }
      });
    }
  }

  $("#breakout_question").popover({
    html: true,
    content: function(){
      var active_price = $(".cs-active-price");
      return $('<table class="table-condensed">')
        .append('<tr><td>Base Cost</td><td>' + active_price.attr('base_cost') + '</tr>')
        .append('<tr><td>Shipping Cost</td><td>' + active_price.attr('shipping_cost') + '</tr>')
        .prop('outerHTML');
    }
  }).hover(function() {
    $(this).popover('show');
  }).mouseleave(function() {
    $(this).popover('hide');
  });

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

    $('#next-button').prop('disabled', false);
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
    if(get_quantity().actual > 0 ) {
      $('#next-button').prop('disabled', false);
    }
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

  function set_quality_tooltip(selected_element) {
    quality_tooltip = $('#quality_toolip');
    if(quality_tooltip.length == 0 ) return;
    selected_quality_option = typeof selected_element !== 'undefined' ? selected_element : $('#purchase_quality_option option:selected');
    quality_tooltip.hide();
    quality_tooltip_text = selected_quality_option.attr('quality_note');
    if( typeof quality_tooltip_text !== 'undefined' && quality_tooltip_text !== '') {
      quality_tooltip.attr('title', quality_tooltip_text).show();
    }
  }

  $('#purchase_quality_option').change(function() {
    var selected_quality_option = $('#purchase_quality_option option:selected');
    set_quality_tooltip(selected_quality_option);
    $('#purchase_product_id').val(selected_quality_option.attr('product-id'));

    var images = JSON.parse(selected_quality_option.attr('images'));

    $('.main-product-image').attr('src', images[0]['large_src']);

    var small_images_div = $('.small-images');
    small_images_div.empty();

    if (images.length > 1) {
      $.each(images, function( index, value ){
        small_images_div.append(
          $('<img class="secondary-product-image" src="http://placehold.it/100x100" alt="alt-text">')
            .attr('alt', value['alt'])
            .attr('src', value['small_src'])
            .data('image-id', value['image_id'])
            .data('large-src', value['large_src'])
        );
      });
    }

    recalc_price();
  });

  $('.secondary-product-image').click(function(){
    $('.main-product-image').attr('src', $(this).data('large-src'));
    $('.main-product-image').attr('alt', $(this).attr('alt'));
    $('#purchase_image_id').attr('value', $(this).data('image-id'));
    set_summary();
  });

  $('#purchase_shipping_option').change(function() {
    var selected_shipping_option = $('#purchase_shipping_option option:selected');
    var delivery_date = selected_shipping_option.attr('delivery_date');
    var delta = parseFloat(selected_shipping_option.attr('delta'));
    var old_price = accounting.unformat($(".cs-active-price").text());
    var new_price = old_price + delta;

    $('#ship_date').text(moment(delivery_date).format('MMMM Do YYYY'));

    var money_text = accounting.formatMoney(new_price);
    $(".cs-active-price").text(money_text)
      .attr('base_cost', selected_shipping_option.attr('base_cost'))
      .attr('shipping_cost', selected_shipping_option.attr('shipping_cost'));

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
      option.text(option_text);
    });
  });

  $('#need_it_sooner').click(function() {
    $('#need_it_sooner').hide();
    $('#shipping_option_group').show();
  });

  $('#purchase-size .product-size').change(function() {
    var sum = 0;

    $('#next-button').prop('disabled', !(get_quantity().actual > 0));
    $('.cs-purchase-submit').prop('disabled', true);
    $('#ship_date').text('--');
    $('#purchase-size .product-size').each(function() { sum += parseInt('0'+ $(this).val()) });
    $('.total-qty span:last').text(sum);

    recalc_price();
  });

  function set_address_id() {
    var address_id = $('#purchase_ship_to_zip option:selected').attr('data-id');
    $('#purchase_address_id').val(address_id);
  }

  $('img').error(function(){
    var img_element = $(this);
    img_element.attr('src','/images/px_logo.png');
    if(img_element.hasClass('top-logo')) {
      img_element.width(600).height(220);
    }
  });
});

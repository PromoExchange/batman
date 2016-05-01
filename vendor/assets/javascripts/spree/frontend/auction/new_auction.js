$(function() {

  // if ($('.cs-page').length > 0) {
  //   $(".cs-footer").addClass("cs-footer-bottom");
  // }

  $("#auction_logo_id").imagepicker({
    hide_select: false
  });

  $('.swatch-clickable').each(function() {
    $(this).attr('title', $(this).attr('name'));
  });

  $('.swatch-clickable').tooltip();

  if( $('#auction_clone_id').val() === "") {
    $('#auction_pms_colors').tagsinput({
      itemValue: 'id',
      itemText: 'text',
      maxTags: 4
    });
  }

  $(".swatch-clickable").click(function() {
    $('#auction_pms_colors').tagsinput('add', {
      id: $(this).attr('id'),
      text: $(this).attr('name')
    });
  });

  $("#auction_imprint_method_id").change(function(e) {
    $('#auction_pms_colors').val('');
    $("div.imprint_swatch").hide();
    var val = $("#auction_imprint_method_id option:selected").val();
    var show_swatches = "div.imprint_swatch_";
    show_swatches += val;
    $(show_swatches).show();

    if ($(show_swatches).length > 0) {
      $("div.imprint_swatch_custom").show();
      $("div.color-hideable").show(750);
    } else {
      $("div.color-hideable").hide(750);
    }

    $("div.custom-color-hideable").hide(750);
  });

  function customerList(url) {
    var key = $("#new-auction").data("key");
    var selected_id = $("#new-auction ul.customer-listing").data('id');
    var simple_template = _.template("<li class='list-group-item'>${value}</li>");

    $.ajax( {
      type: 'GET',
      data: {
        format: 'json'
      },
      url: url,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        var trHTML = '';
        if (data.length > 0) {
          action_template = _.template("<input type='radio' value='${customer_id}' name='auction[customer_id]' id='auction_customer_id_${customer_id}' ${selected}/> <label for='auction_customer_id'>${name}</label>");
          $.each(data, function(i, item) {
            var name = '';
            if (item.payment_type == 'cc') {
              name = item.brand+' '+item.last_4_digits;
            } else {
              name = item.brand+'#'+item.last_4_digits;
            }
            var selected = '';
            if (item.id == selected_id) {
              selected = 'checked';
            }

            trHTML += simple_template({
              value: action_template ({
                customer_id: item.id,
                name: name,
                selected: selected
              })
            });
          });
        } else {
          trHTML += simple_template({
            value: 'Add Account'
          });
        }
        $("#new-auction ul.customer-listing").html(trHTML);
      }
    });
  }

  $("#auction_payment_method").change(function(e) {
    var val = $("#auction_payment_method option:selected").val();
    var url = '';
    if(val == 'Credit Card') {
      $('.customer-hideable').show();
      url = '/api/charges?type=credit_card';
      customerList(url);
    } else if(val == 'Check') {
      $('.customer-hideable').show();
      url = '/api/charges?type=check';
      customerList(url);
    } else {
      $('.customer-hideable').hide();
    }
  });

  if ($("#auction_payment_method option:selected").val() == 'Credit Card') {
    $('.customer-hideable').show();
    customerList('/api/charges?type=credit_card');
  }

  if ($("#auction_payment_method option:selected").val() == 'Check') {
    $('.customer-hideable').show();
    customerList('/api/charges?type=check');
  }

  $('.payment-question').tooltip();

  $("#invite-sellers-link").click(function() {
    $("invite-sellers-form")[0].reset();
    var invited_sellers = $("auction_invited_sellers").val();
    if(typeof invited_sellers === 'undefined' ) return true;
    var sellers_array = invited_sellers.split(';');
    $.each(sellers_array, function(index,value) {
      var email_field_id = '#seller_address'+(index+1);
      $(email_field_id).val(value);
    });
  });

  $("#invite-sellers-submit").click(function() {
    var email_aggregation = '';
    for (var i = 1; i <= 10; i++) {
      var email_value_id = '#seller_address'+(i);
      var email_val = $(email_value_id).val();
      if(typeof email_val === 'undefined' ) break;
      email_aggregation += email_val + ';';
    }
    $("#auction_invited_sellers").val(email_aggregation);
  });

  $('.custom-swatch-clickable').click(function() {
    $("div.custom-color-hideable").show(750);
  });

  $('.custom-swatch-clickable').tooltip();

  var delay = (function(){
    var timer = 0;
    return function(callback, ms){
      clearTimeout (timer);
      timer = setTimeout(callback, ms);
      };
  })();

  $('#auction-size .product-size').keyup(function() {
    if($('#address_drop').val() === '') {
      return;
    }

    delay(function(){
      var sum = 0;
      $('#auction-size .product-size').each(function() {
       sum += parseInt('0'+ $(this).val());
      });
      $('.total-qty span:last').text(sum);
      var min = parseInt($("#auction-size").attr('min-quantity'));
      $(".cs-active-price").hide();
      if (sum >= min) {
        $("#price-spin").show();
        var auction_clone_id = $("#auction_clone_id").val();
        var api_key = $('#new-auction').attr('data-key');
        var url = '/api/auctions/'+auction_clone_id+'/best_price?quantity='+sum;
        $.ajax({
          type: 'GET',
          contentType: "application/json",
          url: url,
          headers: {
            'X-Spree-Token': api_key
          },
          success: function(data) {
            var money_text = accounting.formatMoney((parseFloat(data.best_price)));
            $(".cs-active-price").text(money_text);
            $("#price-spin").hide();
            $(".cs-active-price").show();
          },
          error: function(data) {
            $(".cs-active-price").text('No Price found');
            $("#price-spin").hide();
            $(".cs-active-price").show();
          }
        });
      }
    },200);
  });
});

$(document).ready(function(){
  $("div.imprint_swatch").hide();
  var val = $("#auction_imprint_method_id option:selected").val();
  var show_swatches = "div.imprint_swatch_";
  show_swatches += val;
  $(show_swatches).show();

  if ($(show_swatches).length > 0) {
    $("div.imprint_swatch_custom").show();
    $("div.color-hideable").show(750);
  } else {
    $("div.color-hideable").hide(750);
  }

  if( $("#auction_custom_pms_colors").val() ) {
    $("div.custom-color-hideable").show(750);
  } else {
    $("div.custom-color-hideable").hide(750);
  }

  $(".selected-pms").click(function() {
    $('#auction_pms_colors').tagsinput('add', {
      id: $(this).attr('id'),
      text: $(this).attr('name')
    });
  });

  $(".selected-pms").click();
});

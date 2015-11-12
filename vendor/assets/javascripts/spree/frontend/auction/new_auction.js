$(function() {
  $("#auction_logo_id").imagepicker({
    hide_select: false
  });

  $('.swatch-clickable').each(function() {
    $(this).attr('title', $(this).attr('name'));
  });

  $('.swatch-clickable').tooltip();

  $('#auction_pms_colors').tagsinput({
    itemValue: 'id',
    itemText: 'text',
    maxTags: 4
  });

  $(".swatch-clickable").click(function() {
    $('#auction_pms_colors').tagsinput('add', {
      id: $(this).attr('id'),
      text: $(this).attr('name')
    });
  });

  $("#auction_imprint_method_id").change(function(e) {
    $("div.imprint_swatch").hide();
    var val = $("#auction_imprint_method_id option:selected").val();
    var show_swatches = "div.imprint_swatch_";
    show_swatches += val;
    $(show_swatches).show();
    $("div.imprint_swatch_custom").show();

    var selected = $("#auction_imprint_method_id option:selected").text();
    var found_index = $.inArray(selected, ['Blank','Deboss','Engrave']);
    if( found_index === -1 ) {
      $("div.color-hideable").show(750);
    } else {
      $("div.color-hideable").hide(750);
    }

    $("div.custom-color-hideable").hide(750);
  });

  function customerList(url) {
    var key = $("#new-auction").data("key");
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
          action_template = _.template("<input type='radio' value='${customer_id}' name='auction[customer_id]' id='auction_customer_id_${customer_id}'/> <label for='auction_customer_id'>${name}</label>");
          $.each(data, function(i, item) {
            if (item.payment_type == 'cc') {
              var name = item.brand+' '+item.last_4_digits;
            } else {
              var name = item.brand+'#'+item.last_4_digits;
            }

            trHTML += simple_template({
              value: action_template ({
                customer_id: item.id,
                name: name
              })
            });
          })
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

    if(val == 'Credit Card') {
      $('.customer-hideable').show();
      var url = '/api/charges?type=credit_card';
      customerList(url)
    } else if(val == 'Check') {
      $('.customer-hideable').show();
      var url = '/api/charges?type=check'
      customerList(url)
    } else {
      $('.customer-hideable').hide();
    }
  });

  if ($("#auction_payment_method option:selected").val() == 'Credit Card') {
    $('.customer-hideable').show();
    var url = '/api/charges?type=credit_card';
    customerList(url)
  }

  if ($("#auction_payment_method option:selected").val() == 'Check') {
    $('.customer-hideable').show();
    var url = '/api/charges?type=check'
    customerList(url)
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
});

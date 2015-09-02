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
    maxTags: 2
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
    if(val == 21 || val == 2 || val == 19) {
      show_swatches += val;
    }
    $(show_swatches).show();

    var selected = $("#auction_imprint_method_id option:selected").text();
    var found_index = $.inArray(selected, ['Blank','Deboss','Engrave']);
    if( found_index === -1 ) {
      $("div.color-hideable").show(750);
    } else {
      $("div.color-hideable").hide(750);
    }
  });

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
});

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

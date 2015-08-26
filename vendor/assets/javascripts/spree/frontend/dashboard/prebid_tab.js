$(function() {
  $('tbody').on('click', 'button.open-prebid', function(e) {
    var row = $(this).closest('tr');
    var eqp_flag = row.find('td.eqp-flag').html();
    var eqp_discount = row.find('td.eqp-discount').html();
    var markup = row.find('td.markup').html();
    var seller_id = row.attr('data-id');
    $('#prebid-form > #seller-id').val(seller_id);
    $("#eqp-flag-edit").prop("checked", (eqp_flag === 'Yes'));
    $("#eqp-discount-edit").val(eqp_discount);
    $("#markup-edit").val(markup);
  });

  $('#prebid-submit').click(function(e) {
    var key = $('#seller-live-auction-table').attr('data-key');
    var seller_id = $('#prebid-form > #seller-id').val();
    var eqp_flag = $("#eqp-flag-edit").prop("checked");
    var eqp_discount = $("#eqp-discount-edit").val();
    var markup = $("#markup-edit").val();
    var prebids_url = '/factoryprebid/';

    eqp_discount /= 100;
    markup /= 100;

    var message = {
      seller_id: seller_id,
      eqp_flag: eqp_flag,
      eqp_discount: eqp_discount,
      markup: markup
    };

    $.ajax({
      type: 'POST',
      contentType: "application/json",
      data: JSON.stringify(message),
      url: prebids_url,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        var eqp_flag_cell_id = "#prebid-" + seller_id + " > td.eqp-flag";
        var eqp_discount_cell_id = "#prebid-" + seller_id + " > td.eqp-discount";
        var markup_cell_id = "#prebid-" + seller_id + " > td.markup";

        $(markup_cell_id).html((markup * 100).toFixed(2));
        $(eqp_discount_cell_id).html((eqp_discount * 100).toFixed(2));
        if(eqp_flag === true) {
          $(eqp_flag_cell_id).html('Yes');
        } else {
          $(eqp_flag_cell_id).html('No');
        }
        alert('Prebid settings updated');
      },
      error: function(data) {
        alert('Failed to update prebid settings');
      }
    });
  });
});

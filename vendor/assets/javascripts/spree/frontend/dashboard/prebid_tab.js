$(function() {

  $('tbody').on('click', 'button.open-prebid', function(e) {
    var row = $(this).closest('tr');
    var live_flag = row.find('td.live-flag').html();
    var eqp_flag = row.find('td.eqp-flag').html();
    var eqp_discount = row.find('td.eqp-discount').html();
    var markup = row.find('td.markup').html();
    var prebid_id = row.attr('data-id');
    $('#prebid-form > #prebid-id').val(prebid_id);
    $("#eqp-flag-edit").prop("checked", (eqp_flag === 'Yes'));
    $("#live-flag-edit").prop("checked", (live_flag === 'Yes'));
    $("#eqp-discount-edit").val(eqp_discount);
    $("#markup-edit").val(markup);
  });

  $('#prebid-submit').click(function(e) {
    var key = $('#seller-live-auction-table').attr('data-key');
    var prebid_id = $('#prebid-form > #prebid-id').val();
    var eqp_flag = $("#eqp-flag-edit").prop("checked");
    var live_flag = $("#live-flag-edit").prop("checked");
    var eqp_discount = $("#eqp-discount-edit").val();
    var markup = $("#markup-edit").val();
    var prebids_url = '/api/prebids/' + prebid_id;

    eqp_discount /= 100;
    markup /= 100;

    var message = {
      live: live_flag,
      eqp: eqp_flag,
      eqp_discount: eqp_discount,
      markup: markup
    };

    $.ajax({
      type: 'PUT',
      contentType: "application/json",
      data: JSON.stringify(message),
      url: prebids_url,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        var live_flag_cell_id = "#prebid-" + prebid_id + " > td.live-flag";
        var eqp_flag_cell_id = "#prebid-" + prebid_id + " > td.eqp-flag";
        var eqp_discount_cell_id = "#prebid-" + prebid_id + " > td.eqp-discount";
        var markup_cell_id = "#prebid-" + prebid_id + " > td.markup";

        $(markup_cell_id).html((markup * 100).toFixed(3));
        $(eqp_discount_cell_id).html((eqp_discount * 100).toFixed(3));
        if(eqp_flag === true) {
          $(eqp_flag_cell_id).html('Yes');
        } else {
          $(eqp_flag_cell_id).html('No');
        }
        if(live_flag === true) {
          $(live_flag_cell_id).html('Yes');
        } else {
          $(live_flag_cell_id).html('No');
        }
      },
      error: function(data) {
        alert('Failed to update prebid settings, please contact support');
      }
    });
  });
});

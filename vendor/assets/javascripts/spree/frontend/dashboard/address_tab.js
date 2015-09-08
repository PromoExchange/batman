$(function() {
  function set_disabled_deletes() {
    $(".address-delete-button").each(function(i,item) {
      $(item).prop("disabled",false);
    });

    $('input[name="ship-type"]:checked').each(function(i,item) {
      var address_id = $(item).data('id');
      var delete_button = "#address-delete-button-" + address_id;
      $(delete_button).prop('disabled',true);
    });

    $('input[name="bill-type"]:checked').each(function(i,item) {
      var address_id = $(item).data('id');
      var delete_button = "#address-delete-button-" + address_id;
      $(delete_button).prop('disabled',true);
    });
  }

  set_disabled_deletes();

  function send_type(address_type,address_id) {
    var key = $('#address-panel-edit').attr('data-key');
    var user_id = $('#address-panel-edit').attr('data-id');
    var type_url = '/api/pxaddresses/' + address_id + '/type';
    var address_message = {
      user_id: user_id,
      type: address_type
    };
    $.ajax({
      type: 'POST',
      contentType: "application/json",
      data: JSON.stringify(address_message),
      url: type_url,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        set_disabled_deletes();
      },
      error: function(data) {
        alert('Error updating address type!');
      }
    });
  }

  $('.bill-type-radio').click(function(e) {
    var address_id = $(this).data('id');
    send_type('bill',address_id);
  });

  $('.ship-type-radio').click(function(e) {
    var address_id = $(this).data('id');
    send_type('send',address_id);
  });

  $('.address-delete-button').click(function(e) {
    var key = $('#address-panel-edit').attr('data-key');
    var address_id = $(this).data('id');
    var delete_url = '/api/pxaddresses/' + address_id;
    $.ajax({
      type: 'DELETE',
      contentType: "application/json",
      url: delete_url,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        alert('Address record deleted');
        window.location.href = "/dashboards?tab=address";
      },
      error: function(data) {
        alert('Error deleting address!');
      }
    });
  });
});

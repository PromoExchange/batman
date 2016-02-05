$(function() {
  $("#auction-add-save").click(function(e){
    $("#address-errors-div").hide();
    e.preventDefault();
    var key = $('#auction-add-address').attr('data-key');
    var address_url = '/api/pxaddresses/';
    var type = 'POST';
    var saved_address = window.location.href;
    var pxaddress = {
      user_id: $("#user-id").val(),
      company: $("#address_edit_company").val(),
      firstname: $("#address_edit_firstname").val(),
      lastname: $("#address_edit_lastname").val(),
      address1: $("#address_edit_address1").val(),
      address2: $("#address_edit_address2").val(),
      city: $("#address_edit_city").val(),
      state: $("#address_edit_state").val(),
      zipcode: $("#address_edit_zipcode").val(),
      phone: $("#address_edit_phone").val()
    };
    $.ajax({
      type: type,
      contentType: "application/json",
      data: JSON.stringify(pxaddress),
      url: address_url,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        $('#auction-add-address').modal('hide');
        $('#edit-address-modal-form').trigger("reset");
        option_text = data.firstname + ' ' + data.lastname + ': ' + data.address1;
        $('#shipping_address_id')
          .append($("<option></option>")
          .attr('value',data.id)
          .text(option_text));
        var option_string = '#shipping_address_id option[value=' +data.id + ']';
        $(option_string).prop("selected", "selected");
      },
      error: function(data) {
        var errors = JSON.parse(data.responseText);
        $('#address-errors-msg').text(errors.exception);
        $("#address-errors-div").show();
      }
    });
  });
});

$(function() {
  $('#address-new-button').click(function(e) {
    $("#edit-address-modal-form")[0].reset();
    $("#is_edit").val(0);
  });

  $('.address-edit-button').click(function(e) {
    $("#edit-address-modal-form")[0].reset();
    var address_id = $(this).data('id');
    var company_value = $("#address-company-" + address_id).text();
    var firstname_value = $("#address-firstname-" + address_id).text();
    var lastname_value = $("#address-lastname-" + address_id).text();
    var address1_value = $("#address-address1-" + address_id).text();
    var address2_value = $("#address-address2-" + address_id).text();
    var city_value = $("#address-city-" + address_id).text();
    var state_value = $("#address-state-" + address_id).text();
    var zipcode_value = $("#address-zipcode-" + address_id).text();
    var phone_value = $("#address-phone-" + address_id).text();

    $("#address_edit_company").val(company_value);
    $("#address_edit_firstname").val(firstname_value);
    $("#address_edit_lastname").val(lastname_value);
    $("#address_edit_address1").val(address1_value);
    $("#address_edit_address2").val(address2_value);
    $("#address_edit_city").val(city_value);
    $("#address_edit_state").val(state_value);
    $("#address_edit_zipcode").val(zipcode_value);
    $("#address_edit_phone").val(phone_value);
    $("#is_edit").val(1);
    $("#address_id").val(address_id);
  });

  $("#edit-address-save").click(function(e){
    $("#address-errors-div").hide();
    e.preventDefault();
    var key = $('#address-panel-edit').attr('data-key');
    var address_id = $("#address_id").val();
    var address_url = '/api/pxaddresses/';
    var type = 'POST';
    if($("#is_edit").val() == 1) {
      type = 'PUT';
      address_url = '/api/pxaddresses/' + address_id;
    }
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
        alert('Address updated successfully');
        $('#edit-address').modal('hide');
        window.location.href = "/dashboards?tab=address";
      },
      error: function(data) {
        var errors = JSON.parse(data.responseText);
        $('#address-errors-msg').text(errors.exception);
        $("#address-errors-div").show();
      }
    });
  });
});

$(function() { 

  $('#add-account').click(function() {
    $('#add-account-field').show();
  });

  $('#add-card').click(function() {
    $('#add-card-field').show();
  });

  $('.cancel-account').click(function() {
    $('#add-account-field').hide();
  });

  $('.cancel-card').click(function() {
    $('#add-card-field').hide();
  });

  $('tbody').on('click', '.remove-account', function() {
    var accept = confirm("are you sure? you want to Delete this account");
    if (!accept){ return false; }
    alert('Remove Account')
  });

  $('tbody').on('click', '.remove-card', function() {
    var $this = $(this);
    var customer_id = $this.data('id');
    var key = $('#customer-method').attr('data-key');
    var accept = confirm("are you sure? you want to Remove this Card Entry");
    if (!accept){ return false; }
    $("body").css("cursor", "progress");
    $.ajax({
      type: 'POST',
      contentType: "application/json",
      url: '/delete_customer/'+customer_id,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        if (data.error_msg.length) {
          alert(data.error_msg);
        } else {
          alert('Delete card detail');
          $this.parents('tr').hide('slow', function() {
            $(this).remove();
            $("body").css("cursor", "default");
          });
        }
      },
      error: function(data) {
        alert("Unsuccessful delete");
      }
    }); 
  });

  // create customer using stripe

  function stripeResponseHandlerCustomer(status, response) {

    var $form = $('#customer-form');
    var key = $('#customer-method').attr('data-key');

    if (response.error) {
      $form.find('.payment-errors').text(response.error.message);
      $("body").css("cursor", "default");
      $("#payment-submit").prop('disabled', false);
    } else {
      var token = response.id;

      var message = {
        token: token
      };

      $.ajax({
        type: 'POST',
        contentType: "application/json",
        data: JSON.stringify(message),
        url: '/customer',
        headers: {
          'X-Spree-Token': key
        },
        success: function(data) {
          $('#customer-form')[0].reset();
          alert('Save Credit/Debit card detail');
          window.location.href = "/dashboards?tab=payment_method";
        },
        error: function(data) {
          $form.find('.payment-errors').text("Unsuccessful create");
          $("body").css("cursor", "default");
          $("#payment-submit").prop('disabled', false);
        }
      });
    }
  }

  $('#customer-form').submit(function(event) {
    var $form = $(this);
    $("body").css("cursor", "progress");
    $("#payment-submit").prop('disabled', true);
    Stripe.card.createToken($form, stripeResponseHandlerCustomer);
    return false;
  });

});
$(function() {

  function stripeResponseHandler(status, response) {
    var $form = $('#payment-form');
    var key = $('#seller-won-auction-table').attr('data-key');
    if (response.error) {
      // Show the errors on the form
      $("body").css("cursor", "default");
      $form.find('.payment-errors').text(response.error.message);
      $("#payment-submit").prop('disabled', false);
    } else {
      // response contains id and card, which contains additional card details
      var token = response.id;
      var bid_id = $('#invoice-bid-id').val();

      var message = {
        token: token,
        bid_id: bid_id
      };

      $.ajax({
        type: 'POST',
        contentType: "application/json",
        data: JSON.stringify(message),
        url: '/charges',
        headers: {
          'X-Spree-Token': key
        },
        success: function(data) {
          $('#payment-form')[0].reset();
          $("body").css("cursor", "default");
          $("#payment-submit").prop('disabled', false);
          $('#pay-invoice').modal('hide');
          $('#seller-won-auction-tab').click();
          alert('Payment processed, thank you');
        },
        error: function(data) {
          console.log(data);
          $("body").css("cursor", "default");
          $("#payment-submit").prop('disabled', false);
          $form.find('.payment-errors').text("Unsucessful charge");
        }
      });
    }
  }

  $('#payment-form').submit(function(event) {
    var $form = $(this);
    $("body").css("cursor", "progress");
    $("#payment-submit").prop('disabled', true);
    Stripe.card.createToken($form, stripeResponseHandler);
    return false;
  });

  $('tbody').on('click', 'button.open-invoice', function(e) {
    var bid_id = $(this).data('id');
    $('#invoice-bid-id').val(bid_id);
  });
});

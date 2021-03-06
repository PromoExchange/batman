$(function() {

  function stripeResponseHandler(status, response) {
    var $form = $('#payment-form');
    var key = $('#show-invoice').attr('data-key');
    if (response.error) {
      // Show the errors on the form
      $("body").css("cursor", "default");
      $form.find('.payment-errors').text(response.error.message);
      $("#payment-submit").prop('disabled', false);
    } else {
      // response contains id and card, which contains additional card details
      var token = response.id;
      var auction_id = $('#invoice-auction-id').val();

      var message = {
        token: token,
        auction_id: auction_id
      };

      $.ajax({
        type: 'POST',
        contentType: "application/json",
        data: JSON.stringify(message),
        url: '/api/auctions/' + auction_id + '/order_confirm',
        headers: {
          'X-Spree-Token': key
        },
        success: function(data) {
          $('#payment-form')[0].reset();
          $("body").css("cursor", "default");
          $("#payment-submit").prop('disabled', false);
          alert('Payment processed, thank you');
          window.location.href = "/dashboards?tab=won_auction";
        },
        error: function(data) {
          console.log(data);
          $("body").css("cursor", "default");
          $("#payment-submit").prop('disabled', false);
          $form.find('.payment-errors').text("Unsuccessful charge");
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
    var auction_id = $(this).data('id');
    $('#invoice-auction-id').val(auction_id);
  });

});

$(function() {

  function stripeResponseHandlerBuyer(status, response) {
    var $form = $('#buyer-form');
    var key = $('#show-invoice').attr('data-key');
    if (response.error) {
      // Show the errors on the form
      $("body").css("cursor", "default");
      $form.find('.payment-errors').text(response.error.message);
      $("#payment-submit").prop('disabled', false);
    } else {
      // response contains id and card, which contains additional card details
      var token = response.id;
      var bid_id = $('#bid-id').val();

      var message = {
        token: token
      };

      $.ajax({
        type: 'POST',
        contentType: "application/json",
        data: JSON.stringify(message),
        url: '/api/bids/' + bid_id + '/accept',
        headers: {
          'X-Spree-Token': key
        },
        success: function(data) {
          $('#buyer-form')[0].reset();
          $("body").css("cursor", "default");
          $("#payment-submit").prop('disabled', false);
          alert('Payment processed, thank you');
          window.location.href = "/dashboards";
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

  $('#buyer-form').submit(function(event) {
    var $form = $(this);
    $("body").css("cursor", "progress");
    $("#payment-submit").prop('disabled', true);
    Stripe.card.createToken($form, stripeResponseHandlerBuyer);
    return false;
  });
});

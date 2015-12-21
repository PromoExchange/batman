$(function() {
  $('.accept-link').click(function(e) {
    e.preventDefault();
    var bid = $(this).data('bid');
    var accept = confirm("Are you sure you want to accept this bid of " + accounting.formatMoney(parseFloat(bid))+"?");
    var bid_id = $(this).data('id');
    var preferred = $(this).data('preferred');
    if (!accept){ return false; }
    if (preferred) {
      $('#manage_bid_id').val(bid_id);
      $('#manage-workflow').show('modal');
    } else {
      window.location = "/accept/" + bid_id ;
    }
  });

  $('#manage-workflow input').click(function(){
    var status = $(this).val();
    $('#manage_status').val(status);
  });

  $('#workflow-submit').click(function(){
    var key = $('#show-auction').attr('data-key');
    var bid_id = $('#manage_bid_id').val();
    var message = {
      manage_workflow: $('#manage_status').val()
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
        if (data.manage_status) {
          alert("You've selected a Seller and the use of our project management tool");
          window.location = "/dashboards?tab=purchase_history";
        } else {
          $('#manage-workflow').hide('modal');
          $('#manage-project-off-site').show('modal');
        }
      },
      error: function(data) {
        alert('Failed to accept bid, please contact support');
      }
    });
  });

  $('#accept-bid').click(function() {
    $('.error ul').html('');
    var key = $('#show-invoice').attr('data-key');
    var bid_id = $(this).data('bid');
    var e = document.getElementById('shipping_address_id')
    var ship_id = e.options[e.selectedIndex].value;
    var customer_id = '';
    if($("input[type='radio'][name='auction[customer_id]']:checked")) {
      customer_id = $("input[type='radio'][name='auction[customer_id]']:checked").val();
    }
    $("body").css("cursor", "progress");
    $("#accept-bid").prop('disabled', true);
    var message = {
      ship_id: ship_id,
      customer_id: customer_id
    };

    if (!customer_id) {$(".error ul").append("<li>Payment Option can't be blank</li>")}
    if (!ship_id) {$(".error ul").append("<li>A shipping address is required</li>")}

    if (customer_id && ship_id) {
      $.ajax({
        type: 'POST',
        contentType: "application/json",
        data: JSON.stringify(message),
        url: '/api/bids/' + bid_id + '/accept',
        headers: {
          'X-Spree-Token': key
        },
        success: function(data) {
          if((data.message == 'succeeded') || (data.message == 'pending')) {
            alert('Thank you for using the PromoExchange');
            window.location.reload();
          } else {
            $("body").css("cursor", "default");
            $("#accept-bid").prop('disabled', false);
            $(".error ul").append("<li>" + data.message + "</li>");
          }
        },
        error: function(data) {
          $("body").css("cursor", "default");
          $("#accept-bid").prop('disabled', false);
          $(".error ul").append("<li>Unsuccessful Accept<li>");
        }
      });
    } else {
      $("body").css("cursor", "default");
      $("#accept-bid").prop('disabled', false);
    }
  });

  $('#workflow-continue').click(function() {
    window.location = "/dashboards?tab=purchase_history";
  });

  $('#workflow-rate-seller').click(function() {
    var auction_id = $('.auction-details').data('id')
    $('#rating-auction-id').val(auction_id);
    $('#manage-project-off-site').hide('modal');
    $('#rating-seller').show('modal');
  });
});

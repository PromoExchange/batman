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
        alert("You've selected a Seller and the use of our project management tool");
        window.location = "/dashboards?tab=won_auction";
      },
      error: function(data) {
        alert('Failed to accept bid, please contact support');
      }
    });
  });

  $('#accept-bid').click(function() {
    var key = $('#show-invoice').attr('data-key');
    var bid_id = $(this).data('bid');
    $("body").css("cursor", "progress");
    $("#accept-bid").prop('disabled', true);

    $.ajax({
      type: 'POST',
      contentType: "application/json",
      url: '/api/bids/' + bid_id + '/accept',
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        if((data.message == 'succeeded') || (data.message == 'pending')) {
          alert('Bid accepted successfully');
          window.location.reload();
        } else {
          $("body").css("cursor", "default");
          $("#accept-bid").prop('disabled', false);
          $('#bid-error').find('.payment-errors').text(data.message);
        }
      },
      error: function(data) {
        $("body").css("cursor", "default");
        $("#accept-bid").prop('disabled', false);
        $('#bid-error').find('.payment-errors').text("Unsuccessful Accept");
      }
    });
  });
});

$(function() {
  $('.accept-link').click(function(e) {
    e.preventDefault();
    var bid = $(this).data('bid');
    var accept = confirm("Are you sure you want to accept this bid of " + accounting.formatMoney(parseFloat(bid)));
    var key = $('#show-auction').attr('data-key');
    var bid_id = $(this).data('id');
    var preferred = $(this).data('preferred');
    if (!accept){ return false; }
    if (preferred) {
      $.ajax({
        type: 'POST',
        contentType: "application/json",
        url: '/api/bids/' + bid_id + '/accept',
        headers: {
          'X-Spree-Token': key
        },
        success: function(data) {
          window.location = "/dashboards";
        },
        error: function(data) {
          alert('Failed to accept bid, please contact support');
        }
      });  
    } else {
      window.location = "/accept/" + bid_id ;
    }
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
        $("body").css("cursor", "default");
        $("#accept-bid").prop('disabled', false);
        alert('Bid accept successfully');
        window.location.href = "/dashboards";
      },
      error: function(data) {
        $("body").css("cursor", "default");
        $("#accept-bid").prop('disabled', false);
        alert("Unsuccessful accept");
      }
    });
  });
});

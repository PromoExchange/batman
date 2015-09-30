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
});

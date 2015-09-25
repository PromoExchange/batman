$(function() {
  $('.accept-link').click(function(e) {
    e.preventDefault();
    var bid = $(this).data('bid');
    var accept = confirm("Are you sure you want to accept this bid of " + accounting.formatMoney(parseFloat(bid)));
    var key = $('#show-auction').attr('data-key');
    var bid_id = $(this).data('id');
    var url = '/api/bids/' + bid_id + '/accept';
    if (!accept){ return false; }
    $.ajax({
      type: 'POST',
      contentType: "application/json",
      url: url,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        window.location = "/dashboards";
      },
      error: function(data) {
        alert('Failed to accept bid, please contact support');
        console.log(data);
      }
    });
  });
});

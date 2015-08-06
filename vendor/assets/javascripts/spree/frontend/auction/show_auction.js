$(function() {
  $('.accept-link').click(function(e) {
    e.preventDefault();
    var key = $('#show-auction').attr('data-key');
    var bid_id = $(this).data('id');
    var url = '/api/bids/' + bid_id + '/accept';
    $.ajax({
      type: 'POST',
      contentType: "application/json",
      url: url,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        alert('bid accepted');
        window.location = "/dashboards";
      },
      error: function(data) {
        alert('Failed to accept bid, please contact support');
        console.log(data);
      }
    });
  });
});

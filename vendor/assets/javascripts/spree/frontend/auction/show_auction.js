$(function() {
  $('.accept-link').click(function(e) {
    e.preventDefault();
    var bid = $(this).data('bid');
    var accept = confirm("Are you sure you want to accept this bid of " + accounting.formatMoney(parseFloat(bid)));
    var key = $('#show-auction').attr('data-key');
    var bid_id = $(this).data('id');
    var url = '/api/bids/' + bid_id + '/accept';
    if (!accept){ return false; }
    $('#bid-id').val(bid_id);
    $('#pay-buyer').show('modal');
  });

  $('#payment-close').click(function() {
    $('#pay-buyer').hide('modal');
  });
});

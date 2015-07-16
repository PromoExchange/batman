$(function(){
  $('tbody').on('click','button.open-bid',function(e){
    var auction_id = $(this).data('id');
    var key = $("#seller-live-auction-table").attr("data-key");
    var auction_url = '/api/auctions/' + auction_id;

    console.log(auction_url);
    console.log(key);
    console.log(auction_id);

    $.ajax({
      type: 'GET',
      data:{
        format: 'json'
      },
      url: auction_url,
      headers:{
        'X-Spree-Token': key
      },
      success: function(data){
        $('.modal-footer button').prop('disabled', false);
        $('.fa-spinner').remove();
        $('.modal-body #quantity-requested').text(data.quantity);
        var low_bid = data.lowest_bid;
        if ( low_bid == null){
          $('#lowest-per-unit-price').text('no bids');
          $('#lowest-total-price').text('no bids');
        }else{
          $('#lowest-per-unit-price').text(low_bid/data.quantity);
          $('#lowest-total-price').text(low_bid);
        }
      }
    });
  });
});

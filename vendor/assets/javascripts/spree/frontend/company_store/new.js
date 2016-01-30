$(function(){
  var delay = (function(){
    var timer = 0;
    return function(callback, ms){
      clearTimeout (timer);
      timer = setTimeout(callback, ms);
      };
  })();

  $(".cs-quantity").keyup(function() {
    delay(function(){
      var e = $(".cs-quantity");
      var min = parseInt(e.attr('min'));
      var actual = parseInt(e.val());
      if (actual >= min) {
        var auction_clone_id = $("#auction_clone_id").val();
        var api_key = $('#new-auction').attr('data-key');
        var url = '/api/auctions/'+auction_clone_id+'/best_price?quantity='+actual;
        $.ajax({
          type: 'GET',
          contentType: "application/json",
          url: url,
          headers: {
            'X-Spree-Token': api_key
          },
          success: function(data) {
            var money_text = accounting.formatMoney((parseFloat(data)));
            $(".cs-active-price").text(money_text);
          },
          error: function(data) {
            e.val('No price found');
          }
        });
      }
    },500);
  });
});

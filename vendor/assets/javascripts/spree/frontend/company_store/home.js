$(function(){
  $(".cs-lowest-bid").each(function(){
    return;
    var api_key = $('.cs-title').attr('data-key');
    var url = '/api/auctions/'+$(this).attr('data-key')+'/best_price';
    var e = $(this);
    $.ajax({
      type: 'GET',
      contentType: "application/json",
      url: url,
      headers: {
        'X-Spree-Token': api_key
      },
      success: function(data) {
        var base_text = 'As low as ';
        var money_text = accounting.formatMoney((parseFloat(data)));
        e.text(base_text+money_text);
      },
      error: function(data) {
        e.val('No price found');
      }
    });
  });
});

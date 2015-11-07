$(function() { 

  $("#product_request").on("ajax:success", function(e, data){
    alert("Your PromoExchange swag pro will have product ideas for you soon!");
  }).on("ajax:error", function(e, data){
    var trHTML = '';
    if (data.responseJSON.length > 0) {
      $.each(data.responseJSON, function(i, item) {
        trHTML += '<li>' + item + '</li>';
      });
    }
    $(this).find('.payment-errors ul').html(trHTML);
  });

});
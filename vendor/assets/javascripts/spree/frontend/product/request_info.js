$(function(){
  $('#message-submit').click(function(e) {
    var key = $("#request-info").attr("data-id");
    var owner = $("#buyer-id").val();
    var message = {
      owner_id: owner,
      from_id: owner,
      to_id: $("#seller-id").val(),
      status: 'unread',
      subject: $(".modal-title").text(),
      body: $("#question").val(),
      product_id: $("#product-id").val()
    };
    $.ajax({
      type: 'POST',
      contentType: "application/json",
      data: JSON.stringify(message),
      url: '/api/messages',
      headers:{
        'X-Spree-Token': key
      },
      success: function(data){
        $("#request-info").modal('hide');
      }
    });
    return false;
  });
});

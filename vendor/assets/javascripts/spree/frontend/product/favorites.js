$(function(){
  var is_working = false;
  $('#favorite>i').click(function(e) {
    if(!is_working){
      is_working = true;
      var favorite_id = $('#favorite>i').attr("id");
      var key = $("#request-info").attr("data-id");
      var owner = $("#buyer-id").val();
      var product_id = $("#product-id").val();

      if( $("#favorite>i").hasClass('off') ){
        var message = {
          buyer_id: owner,
          product_id: product_id
        };
        $.ajax({
          type: 'POST',
          contentType: "application/json",
          data: JSON.stringify(message),
          url: '/api/favorites',
          headers:{
            'X-Spree-Token': key
          },
          success: function(data){
            get_favorite()
            is_working = false;
          },
          error: function(data){
            console.log(data)
            is_working = false;
          }
        });
      }else{
        if(typeof favorite_id != 'undefined'){
          var url = '/api/favorites/' + favorite_id;
          $.ajax({
            type: 'DELETE',
            url: url,
            headers:{
              'X-Spree-Token': key
            },
            success: function(data){
              get_favorite()
              is_working = false;
            },
            error: function(data){
              console.log(data)
              is_working = false;
            }
          });
        }
      }
    }
    return false;
  });

  function set_favorite(a){
    if (a == 'on'){
      $("#favorite>i").removeClass('off').addClass('on');
      $("#favorite>span").text('Remove from favorites');
      $("#favorite").delay(100).fadeOut().fadeIn('slow');
    }else{
      $("#favorite>i").removeClass('on').addClass('off');
      $("#favorite>span").text('Add to favorites');
      $("#favorite").delay(100).fadeOut().fadeIn('slow');
    }
  }

  function get_favorite(){
    var key = $("#request-info").attr("data-id");
    var owner = $("#buyer-id").val();
    var product_id = $("#product-id").val();

    if ($.isEmptyObject(owner) ||
        $.isEmptyObject(key) ||
        $.isEmptyObject(product_id)){
      return;
    }

    var url = '/api/favorites?buyer_id='+owner+'&product_id='+product_id;
    $.ajax({
      type: 'GET',
      contentType: "application/json",
      data: {format: 'json'},
      url: url,
      headers:{
        'X-Spree-Token': key
      },
      success: function(data){
        if( data instanceof Array && data.length >= 1){
          $('#favorite>i').attr("id",data[0].id);
          set_favorite('on');
        }else{
          set_favorite('off');
        }
      }
    });
  };
  get_favorite();
});

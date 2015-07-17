$(function(){
  $('#live-auction-tab').click(function(e) {
      $("#live-auction-table > tbody").html("<tr><td class='text-center' colspan='5'><i class='fa fa-spinner fa-pulse fa-3x'></i></td></tr>");
      var key = $("#live-auction-table").attr("data-key");
      var buyer_id = $("#live-auction-table").attr("data-id");
      var auction_url = '/api/auctions?status=open&buyer_id=' + buyer_id;
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
          var trHTML = '';
          if( data.length > 0 ){
            image_template = _.template("<td><img itemprop='image' alt='<%= name %>' src='<%= image %>'</td>");
            lowest_bid_template = _.template("<td><%= lowest_bid %></td>")
            quantity_template = _.template("<td><%= quantity %></td>")
            date_template = _.template("<td><time data-format='%B %e, %Y %l:%M%P' data-local='time' datetime='<%= date %>'><%= date %></time></td>")
            action_template = _.template("<td><a class='cancel' data-confirm='Are you sure?' href='#' data-id='<%= auction_id %>'>Cancel</a></td>")

            $.each(data, function(i,item){
              trHTML += "<tr>"
              trHTML += image_template( {image: item.image_uri, id: item.name} );
              var low_bid = item.lowest_bid;
              if ( low_bid == null){
                low_bid = 'no bids'
              }
              trHTML += lowest_bid_template( {lowest_bid: low_bid});
              trHTML += quantity_template( {quantity: item.quantity});
              trHTML += date_template({date: item.started});
              trHTML += date_template({date: item.ended});
              trHTML += action_template({auction_id: item.id});
              trHTML += "</tr>"
            });
          }else{
            trHTML += "<tr><td class='text-center' colspan='5'>No auctions found!</td></tr>";
          }
          $("#live-auction-table > tbody").html(trHTML);
        }
      });
      $(this).tab('show');
      return false;
  });

  $('#waiting-auction-tab').click(function(e) {
      $("#waiting-auction-table > tbody").html("<tr><td class='text-center' colspan='3'><i class='fa fa-spinner fa-pulse fa-3x'></i></td></tr>");
      var key = $("#live-auction-table").attr("data-key");
      var buyer_id = $("#live-auction-table").attr("data-id");
      var auction_url = '/api/auctions?status=waiting&buyer_id=' + buyer_id;
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
          var trHTML = '';
          if( data.length > 0 ){
            image_row = _.template("<tr><td colspan='3'><img itemprop='image' alt='<%= name %>' src='<%= image %>'><p><%= name %></p></td></tr>")
            bid_cell = _.template("<td><%= email %></td><td><%= bid %></td>")
            action_template = _.template("<td><ul><li><a data-confirm='Are you sure?' rel='nofollow' data-method='get' href='/auctions/<%= auction_id %>/accept_bid'>Accept bid</a></li></ul></td>")

            $.each(data, function(i,item){
              trHTML += image_row( {image: item.image_uri, name: item.name} );
              trHTML += "<tr><td>BIDS</td><td colspan='2'>&nbsp;</td></tr>";
              if( item.bids.length == 0 ){
                trHTML += "<tr><td colspan='3'>NO BIDS</td></tr>"
              }else{
                $.each(item.bids, function(i,bitem){
                  trHTML += '<tr>'
                  trHTML += bid_cell({ email: bitem.email, bid: bitem.bid});
                  trHTML += action_template({ auction_id: item.id });
                  trHTML += '</tr>'
                })
              }
            });
          }else{
            trHTML += "<tr><td class='text-center' colspan='3'>No auctions found!</td></tr>";
          }
          $("#waiting-auction-table > tbody").html(trHTML);
        }
      });
      $(this).tab('show');
      return false;
  });

  $('tbody').on('click','a.cancel',function(e) {
    $(this).closest('tr').addClass('mfd');
    var auction_id = $(this).attr('data-id')
    var auction_url = '/api/auctions/' + auction_id;
    var key = $("#live-auction-table").attr("data-key");
    $.ajax({
      type: 'DELETE',
      data:{
        format: 'json'
      },
      url: auction_url,
      headers:{
        'X-Spree-Token': key
      },
      statusCode: {
        200: function() {
          $('.mfd').fadeOut(400,function(){
            $(this).remove();
          });
        }
      }
    });
    return false;
  });

  $('#live-auction-tab').trigger('click');
});
$(function(){
  $('#seller-live-auction').click(function(e) {
      $("table > tbody").html("<tr><td class='text-center' colspan='5'><i class='fa fa-spinner fa-pulse fa-3x'></i></td></tr>");
      var key = $("#seller-live-auction-table").attr("data-key");
      var seller_id = $("#seller-live-auction-table").attr("data-id");
      var auction_url = '/api/auctions?status=open';

      // Live auctions (open)
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
            action_template = _.template("<td><a class='bid' href='#' data-id='<%= auction_id %>'>Bid</a></td>")

            $.each(data, function(i,item){
              trHTML += "<tr>"
              trHTML += image_template( {image: item.image_uri, id: item.name} );
              trHTML += date_template({date: item.started});
              trHTML += quantity_template( {quantity: item.quantity});
              var low_bid = item.lowest_bid;
              if ( low_bid == null){
                low_bid = 'no bids'
              }
              trHTML += lowest_bid_template( {lowest_bid: low_bid});
              trHTML += lowest_bid_template( {lowest_bid: low_bid});
              trHTML += action_template({auction_id: item.id});
              trHTML += "</tr>"
            });
          }else{
            trHTML += "<tr><td class='text-center' colspan='5'>No auctions found!</td></tr>";
          }
          $("#seller-live-auction-table > tbody").html(trHTML);
        }
      });

      // In the lead auctions (open)
      var auction_url = '/api/auctions?status=open';
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

            $.each(data, function(i,item){
              trHTML += "<tr>"
              trHTML += image_template( {image: item.image_uri, id: item.name} );
              trHTML += date_template({date: item.started});
              trHTML += quantity_template( {quantity: item.quantity});
              var low_bid = item.lowest_bid;
              if ( low_bid == null){
                low_bid = 'no bids'
              }
              trHTML += lowest_bid_template( {lowest_bid: low_bid});
              trHTML += lowest_bid_template( {lowest_bid: low_bid});
              trHTML += "</tr>"
            });
          }else{
            trHTML += "<tr><td class='text-center' colspan='5'>No auctions found!</td></tr>";
          }
          $("#inthelead-auction-table > tbody").html(trHTML);
        }
      });
      $(this).tab('show');
      return false;
  });
  $('#seller-live-auction').trigger('click');
});

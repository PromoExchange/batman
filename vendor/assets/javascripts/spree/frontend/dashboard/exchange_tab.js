$(function(){
  $('#seller-live-auction-tab').click(function(e) {
      var key = $("#seller-live-auction-table").attr("data-key");
      var seller_id = $("#seller-live-auction-table").attr("data-id");
      var auction_url = '/api/auctions?status=open';

      var simple_template = _.template("<td><%= value %></td>");
      var image_template = _.template("<td><img itemprop='image' alt='<%= name %>' src='<%= image %>'</td>");
      var date_template = _.template("<td><time data-format='%B %e, %Y %l:%M%P' data-local='time' datetime='<%= date %>'><%= date %></time></td>");

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
          if (data.length > 0 ){

            action_template = _.template("<td><button type='button' class='btn btn-success open-bid' data-toggle='modal' data-target='#place-bid' data-id='<%= auction_id %>'>Bid</button></td>");

            $.each(data, function(i,item){
              trHTML += "<tr>"
              trHTML += simple_template({value: item.reference});
              trHTML += image_template({image: item.image_uri, id: item.name});
              trHTML += date_template({date: item.started});
              trHTML += simple_template({value: item.quantity});
              var low_bid = item.lowest_bid;
              if (low_bid == null){
                low_bid = 'no bids'
              }
              trHTML += simple_template({value: low_bid});
              trHTML += simple_template({value: low_bid});
              trHTML += action_template({auction_id: item.id});
              trHTML += "</tr>"
            });
          }else{
            trHTML += "<tr><td class='text-center' colspan='7'>No auctions found!</td></tr>";
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
          if (data.length > 0 ){
            $.each(data, function(i,item){
              trHTML += "<tr>"
              trHTML += simple_template({value: item.reference});
              trHTML += image_template({image: item.image_uri, id: item.name});
              trHTML += date_template({date: item.started});
              trHTML += simple_template({value: item.quantity});
              var low_bid = item.lowest_bid;
              if (low_bid == null){
                low_bid = 'no bids'
              }
              trHTML += simple_template({value: low_bid});
              trHTML += simple_template({value: low_bid});
              trHTML += "</tr>"
            });
          }else{
            trHTML += "<tr><td class='text-center' colspan='6'>No auctions found!</td></tr>";
          }
          $("#inthelead-auction-table > tbody").html(trHTML);
        }
      });
      $(this).tab('show');
      return false;
  });
  $('#seller-live-auction-tab').trigger('click');
});

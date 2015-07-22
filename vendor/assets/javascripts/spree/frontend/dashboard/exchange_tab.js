$(function(){
  $('#seller-live-auction-tab').click(function(e) {
      var key = $("#seller-live-auction-table").attr("data-key");
      var seller_id = $("#seller-live-auction-table").attr("data-id");
      var auction_url = '/api/auctions?status=open';

      var simple_template = _.template("<td><%= value %></td>");
      var image_template = _.template("<td><img itemprop='image' alt='<%= name %>' src='<%= image %>'</td>");
      var date_template = _.template("<td><time data-format='%B %e, %Y %l:%M%P' data-local='time' datetime='<%= date %>'><%= date %></time></td>");
      var top3_template = _.template("<td><ul><li><%= bid1 %></li><li><%= bid2 %></li><li><%= bid3 %></li></ul></td>");

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
              trHTML += "<tr>";
              trHTML += simple_template({value: item.reference});
              trHTML += image_template({image: item.image_uri, id: item.name});
              trHTML += date_template({date: item.started});
              trHTML += simple_template({value: item.quantity});

              var num_bids = item.lowest_bids.length;
              var low_bid = 'no bids';
              if (num_bids > 0) {
                low_bid = item.lowest_bids[0].bid;
                if (low_bid === null){
                  low_bid = 'no bids';
                }
              }
              trHTML += simple_template({value: low_bid});

              var bid1_val = 'no bid';
              var bid2_val = 'no bid';
              var bid3_val = 'no bid';

              if (num_bids > 2) {
                bid3_val = item.lowest_bids[2].bid;
                bid2_val = item.lowest_bids[1].bid;
                bid1_val = item.lowest_bids[0].bid;
              }else if (num_bids > 1) {
                bid2_val = item.lowest_bids[1].bid;
                bid1_val = item.lowest_bids[0].bid;
              }else if (num_bids == 1){
                bid1_val = item.lowest_bids[0].bid;
              }
              trHTML += top3_template({bid1: bid1_val, bid2: bid2_val, bid3: bid3_val});
              trHTML += action_template({auction_id: item.id});
              trHTML += "</tr>";
            });
          }else{
            trHTML += "<tr><td class='text-center' colspan='7'>No auctions found!</td></tr>";
          }
          $("#seller-live-auction-table > tbody").html(trHTML);
        }
      });

      // In the lead auctions (open)
      auction_url = '/api/auctions?status=open';
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
              trHTML += "<tr>";
              trHTML += simple_template({value: item.reference});
              trHTML += image_template({image: item.image_uri, id: item.name});
              trHTML += date_template({date: item.started});
              trHTML += simple_template({value: item.quantity});

              var num_bids = item.lowest_bids.length;
              var low_bid = 'no bids';
              if (num_bids > 0) {
                low_bid = item.lowest_bids[0].bid;
                if (low_bid === null){
                  low_bid = 'no bids';
                }
              }
              trHTML += simple_template({value: low_bid});

              var bid1_val = 'no bid';
              var bid2_val = 'no bid';
              var bid3_val = 'no bid';

              if (num_bids > 2) {
                bid3_val = item.lowest_bids[2].bid;
                bid2_val = item.lowest_bids[1].bid;
                bid1_val = item.lowest_bids[0].bid;
              }else if (num_bids > 1) {
                bid2_val = item.lowest_bids[1].bid;
                bid1_val = item.lowest_bids[0].bid;
              }else if (num_bids == 1){
                bid1_val = item.lowest_bids[0].bid;
              }
              trHTML += top3_template({bid1: bid1_val, bid2: bid2_val, bid3: bid3_val});
              trHTML += "</tr>";
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

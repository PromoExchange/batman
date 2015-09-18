$(function() {
  $('#purchase-history-tab').click(function() {
    var key = $("#buyer-purchase-history-table").attr("data-key");
    var buyer_id = $("#buyer-purchase-history-table").attr("data-id");
    var auction_url = '/api/auctions?state=unpaid,waiting_confirmation,order_confirmed,in_production,confirm_receipt&buyer_id=' + buyer_id;

    var reference_template = _.template("<td><a href='/auctions/<%= auction_id %>'><%= reference %></a></td>");
    var simple_template = _.template("<td><%= value %></td>");
    var date_template = _.template("<td><time data-format='%B %e, %Y %l:%M%P' data-local='time' datetime='<%= date %>'><%= date %></time></td>");
    var image_template = _.template("<td><a href='/auctions/<%= auction_id %>'><img itemprop='image' alt='<%= name %>' src='<%= image %>'></a></td>");

    $.ajax({
      type: 'GET',
      data: {
        format: 'json'
      },
      url: auction_url,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        var trHTML = '';
        if (data.length > 0) {
          action_template = _.template("<td><button type='button' class='btn btn-success' data-id='<%= auction_id %>'>Pay</button></td>");
          your_bid_template = _.template("<td id='your_bid_<%= auction_id %>'>no bid</td>");

          $.each(data, function(i, item) {
            trHTML += "<tr>";
            trHTML += reference_template({
              reference: item.reference,
              auction_id: item.id
            });
            trHTML += image_template({
              image: item.image_uri,
              id: item.name,
              auction_id: item.id
            });
            trHTML += date_template({
              date: item.started
            });
            trHTML += simple_template({
              value: item.quantity
            });

            var num_bids = item.bids.length;
            var winning_bid = 'no bids';
            if (num_bids > 0) {
              winning_bid = _.result(_.find(item.bids, function(b) {
                return b.state == 'accepted';
              }), 'bid');
            }
            var action = simple_template({
              value: 'Not completed'
            });
            if (item.state === 'unpaid') {
              action = simple_template({
                value: action_template({
                  auction_id: item.id
                })
              });
            }

            if (item.state === 'waiting_confirmation') {
              var action = simple_template({
                value: 'Awaiting Confirmation'
              });
            } 

            if (item.state === 'order_confirmed') {
              var action = simple_template({
                value: 'Waiting for production'
              });
            } 

            if (item.state === 'in_production') {
              var action = simple_template({
                value: 'In Production'
              });
            }

            if(item.state === 'confirm_receipt') {
              var action = simple_template({
                value: 'Track Shipment'
              })
            }                                      

            trHTML += simple_template({
              value: accounting.formatMoney(parseFloat(winning_bid))
            });
            trHTML += action;
            trHTML += "</tr>";
          });
        } else {
          trHTML += "<tr><td class='text-center' colspan='7'>No auctions found!</td></tr>";
        }
        $("#buyer-purchase-history-table > tbody").html(trHTML);
      }
    });
  });
});

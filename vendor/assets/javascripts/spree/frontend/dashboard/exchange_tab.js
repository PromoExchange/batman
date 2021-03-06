$(function() {
  $('#seller-live-auction-tab').click(function(e) {
    var key = $("#seller-live-auction-table").attr("data-key");
    var seller_id = $("#seller-live-auction-table").attr("data-id");
    var auction_url = '/api/auctions?status=open';

    var reference_template = _.template("<td><a href='/auctions/<%= auction_id %>'><%= reference %></a></td>");
    var simple_template = _.template("<td><%= value %></td>");
    var image_template = _.template("<td><a href='/auctions/<%= auction_id %>'><img itemprop='image' data-toggle='tooltip' title='<%= name %>' data-toggle='tooltip' title='<%= name %>' alt='<%= name %>' src='<%= image %>'></a></td>");
    var date_template = _.template("<td><time data-format='%B %e, %Y %l:%M%P' data-local='time' datetime='<%= date %>'><%= date %></time></td>");
    var top3_template = _.template("<td><ul><li><%= bid1 %></li><li><%= bid2 %></li><li><%= bid3 %></li></ul></td>");

    var auction_ids = [];

    // Live auctions (open)
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
          action_template = _.template("<td><button type='button' id='BidButtonSellerDashboard' class='btn btn-success open-bid' data-toggle='modal' data-target='#place-bid' data-id='<%= auction_id %>'>Bid</button></td>");
          non_action_template = _.template("<td><button type='button' class='btn btn-success open-view'>Bid</button></td>");
          your_bid_template = _.template("<td id='your_bid_<%= auction_id %>'>no bid</td>");

          $.each(data, function(i, item) {
            if (!(item.rejected_bid && item.rejected_bid.seller_id == seller_id)) {
              trHTML += "<tr>";
              trHTML += reference_template({
                reference: item.reference,
                auction_id: item.id
              });
              trHTML += image_template({
                image: item.image_uri,
                name: item.name,
                auction_id: item.id
              });
              trHTML += date_template({
                date: item.started
              });
              trHTML += simple_template({
                value: item.quantity
              });

              var num_bids = item.bids.length;
              var low_bid = 'no bids';
              if (num_bids > 0) {
                auction_ids.push(item.id);
                low_bid = accounting.formatMoney(parseFloat(item.bids[0].bid));
                if (low_bid === null) {
                  low_bid = 'no bids';
                }
              }
              trHTML += your_bid_template({
                auction_id: item.id
              });

              var bid1_val = 'no bid';
              var bid2_val = 'no bid';
              var bid3_val = 'no bid';

              if (num_bids > 2) {
                bid3_val = accounting.formatMoney(parseFloat(item.bids[2].bid));
                bid2_val = accounting.formatMoney(parseFloat(item.bids[1].bid));
                bid1_val = accounting.formatMoney(parseFloat(item.bids[0].bid));
              } else if (num_bids > 1) {
                bid2_val = accounting.formatMoney(parseFloat(item.bids[1].bid));
                bid1_val = accounting.formatMoney(parseFloat(item.bids[0].bid));
              } else if (num_bids == 1) {
                bid1_val = accounting.formatMoney(parseFloat(item.bids[0].bid));
              }
              trHTML += top3_template({
                bid1: bid1_val,
                bid2: bid2_val,
                bid3: bid3_val
              });

              trHTML += action_template({
                auction_id: item.id
              });
              trHTML += "</tr>";
            }
          });
        } else {
          trHTML += "<tr><td class='text-center' colspan='7'>No auctions found!</td></tr>";
        }
        $("#seller-live-auction-table > tbody").html(trHTML);
      }
    }).then(function() {
      var your_bid_url = '/api/bids?state=open&seller_id=' + seller_id;
      $.ajax({
        type: 'GET',
        dataType: 'json',
        url: your_bid_url,
        headers: {
          'X-Spree-Token': key
        },
        success: function(data) {
          if (data.length > 0) {
            $.each(data, function(i, item) {
              var selector = '#your_bid_' + item.auction_id;
              $(selector).text(accounting.formatMoney(parseFloat(item.bid)));
              $(selector).stop().css("background-color", "#FFFF9C")
                .animate({
                  backgroundColor: "#FFFFFF"
                }, 300);
            });
          }
        }
      });
    });

    // In the lead auctions (open)
    auction_url = '/api/auctions?status=open';
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
          $.each(data, function(i, item) {
            trHTML += "<tr>";
            trHTML += simple_template({
              value: item.reference
            });
            trHTML += image_template({
              image: item.image_uri,
              name: item.name
            });
            trHTML += date_template({
              date: item.started
            });
            trHTML += simple_template({
              value: item.quantity
            });

            var num_bids = item.bids.length;
            var low_bid = 'no bids';
            if (num_bids > 0) {
              low_bid = accounting.formatMoney(parseFloat(item.bids[0].bid));
              if (low_bid === null) {
                low_bid = 'no bids';
              }
            }
            trHTML += simple_template({
              value: low_bid
            });

            var bid1_val = 'no bid';
            var bid2_val = 'no bid';
            var bid3_val = 'no bid';

            if (num_bids > 2) {
              bid3_val = accounting.formatMoney(parseFloat(item.bids[2].bid));
              bid2_val = accounting.formatMoney(parseFloat(item.bids[1].bid));
              bid1_val = accounting.formatMoney(parseFloat(item.bids[0].bid));
            } else if (num_bids > 1) {
              bid2_val = accounting.formatMoney(parseFloat(item.bids[1].bid));
              bid1_val = accounting.formatMoney(parseFloat(item.bids[0].bid));
            } else if (num_bids == 1) {
              bid1_val = accounting.formatMoney(parseFloat(item.bids[0].bid));
            }
            trHTML += top3_template({
              bid1: bid1_val,
              bid2: bid2_val,
              bid3: bid3_val
            });
            trHTML += "</tr>";
          });
        } else {
          trHTML += "<tr><td class='text-center' colspan='6'>No auctions found!</td></tr>";
        }
        $("#inthelead-auction-table > tbody").html(trHTML);
      }
    });
    window.history.pushState({}, null, '/dashboards');
    $(this).tab('show');
    return false;
  });

  if ($($('#seller-live-auction-tab').parent()[0]).hasClass('active')) {
    $('#seller-live-auction-tab').trigger('click');
  }

  $('#auction-tab').click(function(){
    window.history.pushState({}, null, '/dashboards');
    $('#seller-live-auction-tab').trigger('click');
  });

  $('#seller-live-auction-table > tbody').on('click', 'button.open-view', function(e) {
    alert("We're sorry. Only sellers that are invited to this auction can bid. Open auctions to the public are coming soon!");
  });
});

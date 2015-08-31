$(function() {
  $('#seller-won-auction-tab').click(function() {
    var key = $("#seller-won-auction").attr("data-key");
    var seller_id = $("#seller-won-auction").attr("data-id");
    var auction_url = '/api/auctions?status=unpaid,completed&seller_id=' + seller_id;

    var reference_template = _.template("<td><a href='/auctions/${auction_id}'>${ reference }</a></td>");
    var simple_template = _.template("<td>${value}</td>");
    var date_template = _.template("<td><time data-format='%B %e, %Y %l:%M%P' data-local='time' datetime='${date}'>${date}</time></td>");
    var image_template = _.template("<td><a href='/auctions/${auction_id}'><img itemprop='image' alt='${name}' src='${image}'></a></td>");

    $.ajax( {
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
          action_template = _.template("<td><button type='button' class='btn btn-success open-invoice' data-toggle='modal' data-target='#pay-invoice' data-id='${auction_id}'>Pay</button></td>");
          your_bid_template = _.template("<td id='your_bid_${auction_id}'>no bid</td>");

          $.each(data, function(i, item) {
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
            var status_text = 'Complete';
            var action = simple_template({
              value: 'No Action required'
            });
            if (item.status === 'unpaid') {
              status_text = 'Invoice payment required';
              action = simple_template({
                value: action_template({
                  auction_id: item.id
                })
              });
            }
            trHTML += simple_template({
              value: status_text
            });
            trHTML += simple_template({
              value: accounting.formatMoney(parseFloat(item.winning_bid.seller_fee))
            });
            trHTML += action;
            trHTML += "</tr>";
          });
        } else {
          trHTML += "<tr><td class='text-center' colspan='7'>No auctions found!</td></tr>";
        }
        $("#seller-won-auction-table > tbody").html(trHTML);
      }
    });
  });
});

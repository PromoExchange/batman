$(function() {
  $('#seller-lost-auction-tab').click(function() {
    var key = $("#seller-won-auction").attr("data-key");
    var seller_id = $("#seller-won-auction").attr("data-id");
    var auction_url = '/api/auctions?lost=yes&seller_id=' + seller_id;

    var reference_template = _.template("<td><a href='/invoices/${auction_id}'>${ reference }</a></td>");
    var simple_template = _.template("<td>${value}</td>");
    var date_template = _.template("<td><time data-format='%B %e, %Y %l:%M%P' data-local='time' datetime='${date}'>${date}</time></td>");
    var image_template = _.template("<td><a href='/invoices/${auction_id}'><img itemprop='image' data-toggle='tooltip' title='${name}' alt='${name}' src='${image}'></a></td>");

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
          $.each(data, function(i, item) {
            trHTML += "<tr>";
            trHTML += reference_template({
              reference: item.reference,
              auction_id: item.id
            });
            trHTML += simple_template({
              value: item.buyer_company
            });
            trHTML += image_template({
              image: item.image_uri,
              name: item.name,
              auction_id: item.id
            });
            trHTML += simple_template({
              value: item.quantity
            });
            // your bid
            // Winning bid
            // Status
            your_bid = '0.00';
            $.each(item.bids, function(i, item) {
              if( item.seller_id === parseInt(seller_id) ) {
                your_bid = item.bid;
              }
            });
            trHTML += simple_template({
              value: accounting.formatMoney(parseFloat(your_bid))
            });
            trHTML += simple_template({
              value: accounting.formatMoney(parseFloat(item.winning_bid.bid))
            });
            trHTML += simple_template({
              value: 'Auction lost'
            });
            trHTML += "</tr>";
          });
        } else {
          trHTML += "<tr><td class='text-center' colspan='7'>No auctions found!</td></tr>";
        }
        $("#seller-lost-auction-table > tbody").html(trHTML);
      }
    });
  });
});

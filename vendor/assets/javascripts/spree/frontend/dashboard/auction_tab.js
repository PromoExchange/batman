$(function() {
  function getAcutionDetail(data) {
    var trHTML = '';
    if (data.length > 0) {
      reference_template = _.template("<td><a href='/auctions/<%= auction_id %>'><%= reference %></a></td>");
      simple_template = _.template("<td><%= value %></td>");
      image_template = _.template("<td><a href='/auctions/<%= auction_id %>'><img itemprop='image' data-toggle='tooltip' title='<%= name %>' alt='<%= name %>' src='<%= image %>'</a></td>");
      date_template = _.template("<td><time data-format='%B %e, %Y %l:%M%P' data-local='time' datetime='<%= date %>'><%= date %></time></td>");
      action_template = _.template("<td><ul><li><a href='/auctions/<%= auction_id %>' data-id='<%= auction_id %>'>Go to Auction</a></li><li><a class='cancel' data-confirm='Are you sure?' href='#' data-id='<%= auction_id %>'>Cancel</a></li></ul></td>");

      $.each(data, function(i, item) {
        trHTML += "<tr>";
        trHTML += reference_template({
          reference: item.reference,
          auction_id: item.id
        });
        trHTML += image_template({
          auction_id: item.id,
          image: item.image_uri,
          name: item.name
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
        trHTML += simple_template({
          value: item.quantity
        });
        trHTML += date_template({
          date: item.started
        });
        trHTML += date_template({
          date: item.ended
        });
        trHTML += action_template({
          auction_id: item.id
        });
        trHTML += "</tr>";
      });
    } else {
      trHTML += "<tr><td class='text-center' colspan='7'>No auctions found!</td></tr>";
    }
    return trHTML;
  }

  $('#live-auction-tab').click(function(e) {
    $("#live-auction-table > tbody").html("<tr><td class='text-center' colspan='7'><i class='fa fa-spinner fa-pulse fa-3x'></i></td></tr>");
    var key = $("#live-auction-table").attr("data-key");
    var buyer_id = $("#live-auction-table").attr("data-id");
    var auction_url = '/api/auctions?status=open&buyer_id=' + buyer_id;
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
        $("#live-auction-table > tbody").html(getAcutionDetail(data));
      }
    });
    $(this).tab('show');
    return false;
  });

  $('#waiting-auction-tab').click(function(e) {
    $("#waiting-auction-table > tbody").html("<tr><td class='text-center' colspan='7'><i class='fa fa-spinner fa-pulse fa-3x'></i></td></tr>");
    var key = $("#live-auction-table").attr("data-key");
    var buyer_id = $("#live-auction-table").attr("data-id");
    var auction_url = '/api/auctions?status=waiting&buyer_id=' + buyer_id;
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
        $("#waiting-auction-table > tbody").html(getAcutionDetail(data));
      }
    });
    $(this).tab('show');
    return false;
  });

  $('tbody').on('click', 'a.cancel', function(e) {
    $(this).closest('tr').addClass('mfd');
    var auction_id = $(this).attr('data-id');
    var auction_url = '/api/auctions/' + auction_id;
    var key = $("#live-auction-table").attr("data-key");
    $.ajax({
      type: 'DELETE',
      data: {
        format: 'json'
      },
      url: auction_url,
      headers: {
        'X-Spree-Token': key
      },
      statusCode: {
        200: function() {
          $('.mfd').fadeOut(400, function() {
            $(this).remove();
          });
        }
      }
    });
    return false;
  });

  $('#auction-tab').click(function(){
    window.history.pushState({}, null, '/dashboards');
  });

  if ($($('#live-auction-tab').parent()[0]).hasClass('active')) {
    $('#live-auction-tab').trigger('click');
  }
});

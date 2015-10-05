$(function() {
  $('#seller-won-auction-tab').click(function() {
    var key = $("#seller-won-auction").attr("data-key");
    var seller_id = $("#seller-won-auction").attr("data-id");
    var auction_url = '/api/auctions?state=unpaid,waiting_confirmation,in_production,send_for_delivery,confirm_receipt,complete&seller_id=' + seller_id;

    var reference_template = _.template("<td><a href='/invoices/${auction_id}'>${ reference }</a></td>");
    var simple_template = _.template("<td>${value}</td>");
    var date_template = _.template("<td><time data-format='%B %e, %Y %l:%M%P' data-local='time' datetime='${date}'>${date}</time></td>");
    var image_template = _.template("<td><a href='/invoices/${auction_id}'><img itemprop='image' alt='${name}' src='${image}'></a></td>");

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
          action_template = _.template("<a class='btn btn-success ${auction_class}' data-id='${auction_id}' href='${url}'>${auction_value}</a>");
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

            var status_text = ''
            var action = ''

            if(item.state === 'unpaid') {
              status_text = 'Invoice Payment Required';
              action = simple_template({
                value: action_template({
                  url: '/invoices/'+item.id, auction_id: item.id, auction_value: 'Pay', auction_class: 'pay'
                })
              });
            }

            if(item.state === 'waiting_confirmation') {
              status_text = 'Waiting for Confirmation';
              action = simple_template({
                value: action_template({
                  url: '/invoices/'+item.id, auction_id: item.id, auction_value: 'Confirm', auction_class: 'confirm'
                })
              });
            }

            if(item.state === 'in_production') {
              status_text = 'In Production';
              action = simple_template({
                value: action_template({
                  url: '#', auction_id: item.id, auction_value: 'Input Tracking Number', auction_class: 'tracking_number'
                })
              });
            }

            if(item.state === 'send_for_delivery') {
              status_text = 'Track Shipment';
              action = simple_template({
                value: action_template({
                  url: '#', auction_id: item.id, auction_value: 'Track Shipment', auction_class: 'track_shipment'
                })
              });
            }

            if(item.state === 'confirm_receipt') {
              status_text = 'Awaiting for Confirm Receipt';
              action = simple_template({
                value: action_template({
                  url: '#', auction_id: item.id, auction_value: 'Track Shipment', auction_class: 'track_shipment'
                })
              });
            }

            if(item.state === 'complete') {
              status_text = 'Completed';
              action = simple_template({
                value: ''
              });
            }

            trHTML += simple_template({
              value: status_text
            });
            trHTML += simple_template({
              value: accounting.formatMoney((parseFloat(item.winning_bid.seller_fee) / (1 - 0.029)) + 0.30)
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

  if ($($('#seller-won-auction-tab').parent()[0]).hasClass('active')) {
    $('#seller-won-auction-tab').trigger('click');
  }

  $('#confirm-order-submit').click(function(){
    var auction_id = $(this).data('id');
    var key = $('#show-invoice').attr('data-key');
    var url = '/api/auctions/' + auction_id + '/order_confirm';
    var accept = confirm("Are you sure you want to Confirm this Order");
    if (!accept){ return false; }
    $.ajax({
      type: 'POST',
      contentType: "application/json",
      url: url,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        window.location = "/dashboards";
      },
      error: function(data) {
        alert('Failed to confirm order, please contact support');
      }
    });
  });

  $('tbody').on('click', '.tracking_number', function(){
    var auction_id = $(this).data('id');
    $('#tracking-auction-id').val(auction_id);
    $('#tracking-number').show('modal');
  });

  $('#tracking-close').click(function(){
    $('#tracking-number').hide('modal');
    $('#trackig-number').val('');
  });

  $('#tracking-submit').click(function(){
    var auction_id = $('#tracking-auction-id').val();
    var key = $('#tracking-number').attr('data-key');
    var tracking_number = $('#trackig-number').val();
    var url = '/api/auctions/' + auction_id + '/tracking';
    $.ajax({
      type: 'POST',
      url: url,
      data: {"tracking_number": tracking_number, format: 'json'},
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        if (data.error_msg.length) {
          alert(data.error_msg);
        } else {
          alert('Tracking number successfully updated.');
          window.location = "/dashboards?tab=won_auction";
        }
      },
      error: function(data) {
        alert('Failed to add tracking, please contact support');
        $('#tracking-close').click();
      }
    });
  });
});

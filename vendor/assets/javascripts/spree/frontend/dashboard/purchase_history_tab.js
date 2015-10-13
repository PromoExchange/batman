$(function() {
  $('#purchase-history-tab').click(function() {
    var key = $("#buyer-purchase-history-table").attr("data-key");
    var buyer_id = $("#buyer-purchase-history-table").attr("data-id");
    var auction_url = '/api/auctions?state=unpaid,waiting_confirmation,create_proof,waiting_proof_approval,in_production,send_for_delivery,confirm_receipt,complete&buyer_id=' + buyer_id;

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
          action_template = _.template("<a class='btn btn-success ${auction_class}' data-id='${auction_id}' href='${url}'>${auction_value}</a>");
          new_window_action_template = _.template("<a class='btn btn-success ${auction_class}' data-id='${auction_id}' target='_blank' href='${url}'>${auction_value}</a>");
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

            var status_text = '';
            var action = '';

            var num_bids = item.bids.length;
            var winning_bid = 'no bids';
            if (num_bids > 0) {
              winning_bid = _.result(_.find(item.bids, function(b) {
                return b.state == 'accepted';
              }), 'bid');
            }
            action = simple_template({
              value: 'Not completed'
            });

            if (item.state === 'waiting_confirmation' || 'unpaid') {
              status_text = 'Awaiting Confirmation';
              action = simple_template({
                value: ''
              });
            }

            if (item.state === 'create_proof') {
              status_text = 'Awaiting Virtual Proof';
              if (item.proof_feedback) {
                status_text = 'Awaiting New Proof';
              }
              action = simple_template({
                value: ''
              });
            }

            if (item.state === 'waiting_proof_approval') {
              status_text = 'View Proof';
              action = simple_template({
                value: action_template({
                  url: '/auctions/'+item.id+'/download_proof', auction_id: item.id, auction_value: 'View Proof', auction_class: 'view_proof'
                }) + action_template({
                  url: '#', auction_id: item.id, auction_value: 'Approve', auction_class: 'approve_proof'
                }) + action_template({
                  url: '#', auction_id: item.id, auction_value: 'Request Changes', auction_class: 'btn-danger reject_proof'
                })
              });
            }

            if (item.state === 'order_confirmed') {
              status_text = 'Waiting for production';
              action = simple_template({
                value: ''
              });
            }

            if (item.state === 'in_production') {
              status_text = 'In Production';
              action = simple_template({
                value: ''
              });
            }

            if(item.state === 'send_for_delivery') {
              status_text = 'Track Shipment';
              if(item.shipping_agent === 'ups') {
                action = simple_template({
                  value: action_template({
                    url: '#', auction_id: item.id, auction_value: 'Track Shipment', auction_class: 'track_shipment'
                  })
                });
              } else {
                var url = 'http://www.fedex.com/Tracking?action=track&tracknumbers=' + item.tracking_number;
                action = simple_template({
                  value: new_window_action_template({
                    url: url, auction_id: item.id, auction_value: 'Track Shipment', auction_class: 'track_shipment_fedex'
                  })
                });
              }
            }

            if(item.state === 'confirm_receipt') {
              status_text = 'Awaiting for Confirm Receipt';
              if( item.shipping_agent === 'ups') {
                action = simple_template({
                  value: action_template({
                    url: '#', auction_id: item.id, auction_value: 'Confirm Receipt', auction_class: 'confirm_receipt'
                  }) + action_template({
                    url: '#', auction_id: item.id, auction_value: 'Track Shipment', auction_class: 'track_shipment'
                  })
                });
              } else {
                var url = 'http://www.fedex.com/Tracking?action=track&tracknumbers=' + item.tracking_number;
                action = simple_template({
                  value: action_template({
                    url: '#', auction_id: item.id, auction_value: 'Confirm Receipt', auction_class: 'confirm_receipt'
                  }) + action_template({
                    url: url, auction_id: item.id, auction_value: 'Track Shipment', auction_class: 'track_shipment_fedex'
                  })
                });
              }
            }

            if(item.state === 'complete') {
              status_text = 'Completed';
              action = simple_template({
                value: ''
              });
              if(!item.review){
                action = simple_template({
                  value: action_template({
                    url: '#', auction_id: item.id, auction_value: 'Review Rating', auction_class: 'review_rating'
                  })
                });
              }
            }

            trHTML += simple_template({
              value: accounting.formatMoney(parseFloat(winning_bid))
            });

            trHTML += simple_template({
              value: status_text
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

  $('tbody').on('click', '.confirm_receipt', function(){
    var auction_id = $(this).data('id');
    var accept = confirm("Are you sure, Confirm Receipt");
    if (!accept){ return false; }
    $('#rating-auction-id').val(auction_id);
    $('#rating-seller').show('modal');
  });

  $('tbody').on('click', '.review_rating', function(){
    var auction_id = $(this).data('id');
    $('#rating-auction-id').val(auction_id);
    $('#rating-seller').show('modal');
  });

  $('#rating').on('click', '.star a', function(){
    var rating = $(this).attr('title');
    $('#select-rating').val(rating);
  });

  $('#rating-submit').on('click', 'button', function(){
    var status = $(this).data(status);
    var auction_id = $('#rating-auction-id').val();
    var key = $('#rating-seller').attr('data-key');
    var url = '/api/auctions/' + auction_id + '/confirmed_delivery';
    var message = {
      rating: $('#select-rating').val(),
      review: $('#rating-review').val(),
      status: status
    };
    $('#rating-seller').hide('modal');
    $.ajax({
      type: 'POST',
      contentType: "application/json",
      data: JSON.stringify(message),
      url: url,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        $('#purchase-history-tab').click();
      },
      error: function(data) {
        alert('Failed to Submit Rating, please contact support');
      }
    });
  });

  $('tbody').on('click', '.approve_proof', function(){
    var auction_id = $(this).data('id');
    var key = $('#buyer-purchase-history-table').attr('data-key');
    var url = '/api/auctions/' + auction_id + '/approve_proof';
    var accept = confirm("Are you sure, Approve Proof");
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
        alert('Failed to Confirmed Receipt, please contact support');
      }
    });
  });

  $('tbody').on('click', '.reject_proof', function(){
    var auction_id = $(this).data('id');
    var accept = confirm("Are you sure, Reject Proof");
    if (!accept){ return false; }
    $('#feedback-auction-id').val(auction_id);
    $('#reject-proof').modal('show');
  });

  $('#feedback-submit').click(function(){
    var auction_id = $('#feedback-auction-id').val();
    var key = $('#buyer-purchase-history-table').attr('data-key');
    var text = $('#reject-proof textarea').val();
    var url = '/api/auctions/' + auction_id + '/reject_proof';
    $.ajax({
      type: 'POST',
      data: {"proof_feedback": text, format: 'json'},
      url: url,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        if (data.error_msg.length) {
          alert(data.error_msg);
        } else {
          alert('Proof Rejected.');
          window.location = "/dashboards";
        }
      },
      error: function(data) {
        alert('Failed to Confirmed Receipt, please contact support');
      }
    });
  });
});

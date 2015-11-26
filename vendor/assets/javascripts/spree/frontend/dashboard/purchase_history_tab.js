$(function() {
  $('#purchase-history-tab').click(function() {
    var key = $("#buyer-purchase-history-table").attr("data-key");
    var buyer_id = $("#buyer-purchase-history-table").attr("data-id");
    var auction_url = '/api/auctions?state=unpaid,in_dispute,waiting_confirmation,create_proof,waiting_proof_approval,in_production,send_for_delivery,confirm_receipt,complete&buyer_id=' + buyer_id;

    var reference_template = _.template("<td><a href='/auctions/<%= auction_id %>'><%= reference %></a></td>");
    var simple_template = _.template("<td><%= value %></td>");
    var date_template = _.template("<td><time data-format='%B %e, %Y %l:%M%P' data-local='time' datetime='<%= date %>'><%= date %></time></td>");
    var image_template = _.template("<td><a href='/auctions/<%= auction_id %>'><img itemprop='image' data-toggle='tooltip' title='<%= name %>' alt='<%= name %>' src='<%= image %>'></a></td>");

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
          action_template = _.template("<a class='btn btn-success ${auction_class}' data-id='${auction_id}' href='${url}'>${auction_value}</a><br/>");
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
              name: item.name,
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
                  }) + new_window_action_template({
                    url: url, auction_id: item.id, auction_value: 'Track Shipment', auction_class: 'track_shipment_fedex'
                  })
                });
              }
            }

            if(item.state === 'confirm_receipt') {
              status_text = 'Awaiting receipt confirmation';
              if( item.shipping_agent === 'ups') {
                action = simple_template({
                  value: action_template({
                    url: '#', auction_id: item.id, auction_value: 'Confirm Receipt', auction_class: 'confirm_receipt'
                  }) + action_template({
                    url: '#', auction_id: item.id, auction_value: 'Track Shipment', auction_class: 'track_shipment'
                  }) + action_template({
                    url: '#', auction_id: item.id, auction_value: 'Reject Order', auction_class: 'reject_order'
                  })
                });
              } else {
                var url = 'http://www.fedex.com/Tracking?action=track&tracknumbers=' + item.tracking_number;
                action = simple_template({
                  value: action_template({
                    url: '#', auction_id: item.id, auction_value: 'Confirm Receipt', auction_class: 'confirm_receipt'
                  }) + action_template({
                    url: url, auction_id: item.id, auction_value: 'Track Shipment', auction_class: 'track_shipment_fedex'
                  }) + action_template({
                    url: url, auction_id: item.id, auction_value: 'Reject Order', auction_class: 'reject_order'
                  })
                });
              }
            }

            if (item.state === 'in_dispute') {
              status_text = 'Order being disputed';
              action = simple_template({
                value: action_template({
                  url: '#', auction_id: item.id, auction_value: 'Dispute Resolved', auction_class: 'dispute_resolved'
                }) + action_template({
                  url: '#', auction_id: item.id, auction_value: 'Cancel', auction_class: 'cancel_order'
                })
              });
            }

            if(item.state === 'complete') {
              status_text = 'Completed';
              action = simple_template({
                value: ''
              });
              if(!item.review){
                action = simple_template({
                  value: action_template({
                    url: '#', auction_id: item.id, auction_value: 'Rate Seller', auction_class: 'review_rating'
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
    window.history.pushState({}, null, '/dashboards?tab=purchase_history');
  });

  if ($($('#purchase-history-tab').parent()[0]).hasClass('active')) {
    $('#purchase-history-tab').trigger('click');
  }

  $('tbody').on('click', '.reject_order', function(){
    var auction_id = $(this).data('id');
    var reject = confirm("Are you sure you want to reject the order?");
    if (!reject){ return false; }
    $('#reject-order-auction-id').val(auction_id);
    $('#reject-order-modal').show('modal');
  });

  $('tbody').on('click', '.dispute_resolved', function(){
    var auction_id = $(this).data('id');
    var url = '/api/auctions/' + auction_id + '/resolve_dispute';
    var key = $('#buyer-purchase-history-table').attr('data-key');
    $.ajax({
      type: 'POST',
      contentType: "application/json",
      url: url,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        $('#purchase-history-tab').click();
      },
      error: function(data) {
        alert('Failed to resolve dispute, please contact support');
      }
    });
  });

  $('tbody').on('click', '.confirm_receipt', function(){
    var auction_id = $(this).data('id');
    var accept = confirm("Are you sure you want to confirm your order was received accurate and in full?");
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

  $('tbody').on('click', '.cancel_order', function(e) {
    var auction_id = $(this).attr('data-id');
    var auction_url = '/api/auctions/' + auction_id;
    var key = $('#buyer-purchase-history-table').attr('data-key');
    $.ajax( {
      type: 'DELETE',
      url: auction_url,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        $('#purchase-history-tab').click();
      },
      error: function(data) {
        alert('Failed to cancel order, please contact support');
      }
    });
    return false;
  });

  $('#reject-order-submit').on('click', 'button', function(){
    var auction_id = $('#reject-order-auction-id').val();
    var key = $('#reject-order-modal').attr('data-key');
    var url = '/api/auctions/' + auction_id + '/reject_order';
    var message = {
      rejection_reason: $('#rejection-reason').val()
    };
    $('#reject-order-modal').hide('modal');
    if( $('#rejection-reason').val() === '') return false;
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
        alert('Failed to reject order, please contact support');
      }
    });
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
    var accept = confirm("Are you sure you want to approve this proof?");
    if (!accept){ return false; }
    $.ajax({
      type: 'POST',
      contentType: "application/json",
      url: url,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        $('#purchase-history-tab').click();
      },
      error: function(data) {
        alert('Failed to Confirmed Receipt, please contact support');
      }
    });
  });

  $('tbody').on('click', '.reject_proof', function(){
    var auction_id = $(this).data('id');
    var accept = confirm("Are you sure you want to reject the proof?");
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
          $('#purchase-history-tab').click();
          $('#reject-proof').modal('hide');
          $('#reject-proof textarea').val('');
        }
      },
      error: function(data) {
        alert('Failed to Confirmed Receipt, please contact support');
      }
    });
  });
});

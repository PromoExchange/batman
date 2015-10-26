$(function() {
  $('#seller-won-auction-tab').click(function() {
    var key = $("#seller-won-auction").attr("data-key");
    var seller_id = $("#seller-won-auction").attr("data-id");
    var auction_url = '/api/auctions?state=unpaid,waiting_confirmation,create_proof,waiting_proof_approval,in_production,send_for_delivery,confirm_receipt,complete&seller_id=' + seller_id;
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
          action_template = _.template("<a class='btn btn-success ${auction_class}' data-id='${auction_id}' data-feedback='${feedback}' href='${url}'>${auction_value}</a>");
          new_window_action_template = _.template("<a class='btn btn-success ${auction_class}' data-id='${auction_id}' data-feedback='${feedback}' target='_blank' href='${url}'>${auction_value}</a>");
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

            var status_text = '';
            var action = '';

            if(item.state === 'unpaid') {
              status_text = 'Invoice Payment Required';
              action = simple_template({
                value: action_template({
                  feedback: '', url: '/invoices/'+item.id, auction_id: item.id, auction_value: 'Pay', auction_class: 'pay'
                })
              });
            }

            if(item.state === 'waiting_confirmation') {
              status_text = 'Waiting for Confirmation';
              action = simple_template({
                value: action_template({
                  feedback: '', url: '/invoices/'+item.id, auction_id: item.id, auction_value: 'Confirm', auction_class: 'confirm'
                })
              });
            }

            if (item.state === 'create_proof') {
              status_text = 'Upload Proof';
              action = simple_template({
                value: action_template({
                  feedback: '', url: '#', auction_id: item.id, auction_value: 'Upload Proof', auction_class: 'upload_proof'
                })
              });

              if (item.proof_feedback) {
                status_text = 'Upload New Proof';
                action = simple_template({
                  value: action_template({
                    feedback: '', url: '#', auction_id: item.id, auction_value: 'Upload New Proof', auction_class: 'upload_proof'
                  }) + action_template({
                    feedback: item.proof_feedback, url: '#', auction_id: item.id, auction_value: 'Feedback', auction_class: 'view_feedback'
                  })
                });
              }
            }

            if (item.state === 'waiting_proof_approval') {
              status_text = 'Awaiting proof review';
              action = simple_template({
                value: action_template({
                  feedback: '', url: '/auctions/'+item.id+'/download_proof', auction_id: item.id, auction_value: 'View Proof', auction_class: 'view_proof'
                })
              });
            }

            if(item.state === 'in_production') {
              status_text = 'In Production';
              action = simple_template({
                value: action_template({
                  feedback: '', url: '#', auction_id: item.id, auction_value: 'Input Tracking Number', auction_class: 'tracking_number'
                })
              });
            }

            if(item.state === 'send_for_delivery') {
              status_text = 'Track Shipment';
              if(item.shipping_agent === 'ups') {
                action = simple_template({
                  value: action_template({
                    feedback: '', url: '#', auction_id: item.id, auction_value: 'Track Shipment', auction_class: 'track_shipment'
                  })
                });
              } else {
                var url = 'http://www.fedex.com/Tracking?action=track&tracknumbers=' + item.tracking_number;
                action = simple_template({
                  value: new_window_action_template({
                    feedback: '', url: url, auction_id: item.id, auction_value: 'Track Shipment', auction_class: 'track_shipment_fedex'
                  })
                });
              }
            }

            if(item.state === 'confirm_receipt') {
              status_text = 'Delivered';
              action = simple_template({
                value: action_template({
                  feedback: '', url: '#', auction_id: item.id, auction_value: 'Track Shipment', auction_class: 'track_shipment'
                })
              });
            }

            if(item.state === 'in_dispute') {
              status_text = 'Order being disputed';
              action = simple_template({
                value: ''
              });
            }

            if(item.state === 'complete') {
              var rating_status = '';
              if(item.review) {
                for (var i = 1; i < 6; i++) {
                  if(i <= item.review.rating) {
                    rating_status += '<span class="star won-star">☆</span>';
                  } else {
                    rating_status += '<span class="star">☆</span>';
                  }
                }
              }

              status_text = 'Completed <br>' + rating_status;
              action = simple_template({
                value: ''
              });
              if(item.payment_claimed === false) {
                status_text = 'Payment ready <br>' + rating_status;
                action = simple_template({
                  value: action_template({
                    feedback: '',url: '#', auction_id: item.id, auction_value: 'Claim Payment', auction_class: 'claim-payment'
                  })
                });
              }
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

  $('#confirm-order-submit').click(function() {
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

  $('tbody').on('click', '.claim-payment', function(){
    var auction_id = $(this).data('id');
    $('#claim-payment-auction-id').val(auction_id);
    $('#claim-payment-submit').prop('disabled', false);
    $('#claim-payment-modal').show('modal');
  });

  $('#claim-payment-close').click(function() {
    $('#claim-payment-modal').hide('modal');
    $('.bank-field').val('');
  });

  $('#paymenttype_paper_check').click(function() {
    $('.bank-field').prop('disabled', true);
    $('#paper_payment_div').show();
    $('#ach_payment_div').hide();
  });

  $('#paymenttype_ach_transfer').click(function() {
    $('.bank-field').prop('disabled', false);
    $('#paper_payment_div').hide();
    $('#ach_payment_div').show();
  });

  $('#claim-payment-submit').click(function() {
    $('#claim-payment-submit').prop('disabled', true);
    var auction_id = $('#claim-payment-auction-id').val();
    var key = $('#claim-payment-modal').attr('data-key');
    var bank_name = $('#bank-name').val();
    var bank_branch = $('#bank-branch').val();
    var bank_routing = $('#bank-routing').val();
    var bank_acct_number = $('#bank-acct-number').val();
    var url = '/api/auctions/' + auction_id + '/claim_payment';
    var message = {
      payment_type: $('input[name=paymenttype]:checked').val(),
      bank_name: $('#bank-name').val(),
      bank_branch: $('#bank-branch').val(),
      bank_routing: $('#bank-routing').val(),
      bank_acct_number: $('#bank-acct-number').val()
    };
    $.ajax({
      type: 'POST',
      url: url,
      contentType: 'application/json',
      data: JSON.stringify(message),
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        alert('Payment claim requested.');
        window.location = "/dashboards?tab=won_auction";
      },
      error: function(data) {
        alert('Failed to process payment claim, please contact support');
        $('#claim-payment-close').click();
      }
    });
  });

  $('tbody').on('click', '.tracking_number', function() {
    var auction_id = $(this).data('id');
    $('#tracking-auction-id').val(auction_id);
    $('#tracking-number').show('modal');
  });

  $('#tracking-close').click(function() {
    $('#tracking-number').hide('modal');
    $('#trackig-number').val('');
  });

  $('#tracking-submit').click(function() {
    var auction_id = $('#tracking-auction-id').val();
    var key = $('#tracking-number').attr('data-key');
    var url = '/api/auctions/' + auction_id + '/tracking';
    var message = {
      agent_type: $('input[name=agenttype]:checked').val(),
      tracking_number: $('#trackig-number').val()
    };
    $.ajax({
      type: 'POST',
      url: url,
      contentType: 'application/json',
      data: JSON.stringify(message),
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

  $('tbody').on('click', '.upload_proof', function(){
    var auction_id = $(this).data('id');
    $('#id').val(auction_id);
    $('#proof-modal').modal('show');
  });

  $('tbody').on('click', '.view_feedback', function(){
    var auction_id = $(this).data('id');
    var feedback = $(this).data('feedback');
    $('#view-feedback').html('"' + feedback + '"');
    $('#feedback-button').attr('href', '/auctions/'+ auction_id+'/download_proof');
    $('#proof-feedback').modal('show');
  });
});

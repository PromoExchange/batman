$(function() {

  $('#product-ideas-tab').click(function() {
    var key = $("#buyer-product-ideas-table").attr("data-key");
    var url = 'api/product_requests';

    var simple_template = _.template("<td class='product_request_list'><%= value %> <table class='table table-striped idea-listing'><tr><td></td></tr></table></td>");

    $.ajax({
      type: 'GET',
      data: {
        format: 'json'
      },
      url: url,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        var trHTML = '';
        if (data.length > 0) {

          action_template = _.template("<a class='product_request_title' data-id='${product_request_id}'><span class='glyphicon glyphicon-chevron-right'></span>${name}</a>");

          $.each(data, function(i, item) {
            trHTML += "<tr>";

            start_auction = action_template({
              product_request_id: item.id,
              name: item.title
            });

            trHTML += simple_template({
              value: start_auction
            });

            trHTML += "</tr>";
          });
        } else {
          trHTML += "<tr><td class='text-center' colspan='4'>if you have submitted a request to have a PromoExchange rep come up with product suggestions, you should expect those suggestions to be displayed here within the next couple of days.</td></tr>";
        }
        $("#buyer-product-ideas-table > tbody").html(trHTML);
      }
    });
  });

  $('tbody').on('click', '.product_request_title', function(){

    if($(this).find('span').hasClass('glyphicon-chevron-down')) {

      $(this).find('span').removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-right');
      $(this).parent().find('table').hide();

    } else {

      var key = $("#buyer-product-ideas-table").attr("data-key");
      var product_request_id = $(this).data("id");
      var $this = $(this);
      var url = 'api/request_ideas?state=open,complete&product_request_id='+product_request_id;

      var simple_template = _.template("<td><%= value %></td>");
      var image_template = _.template("<td class='image_idea'><a href='${url}'><img itemprop='image' data-toggle='tooltip' title='${name}' alt='${name}' src='${image}'><p>${value}</p></a></td>");

      $.ajax({
        type: 'GET',
        data: {
          format: 'json'
        },
        url: url,
        headers: {
          'X-Spree-Token': key
        },
        success: function(data) {
          var trHTML = '';
          if (data.length > 0) {

            action_template = _.template("<a class='btn ${product_class}' data-id='${request_idea_id}' href='${url}'>${name}</a>");

            $.each(data, function(i, item) {
              trHTML += "<tr>";

              request_sample = action_template({
                product_class: 'btn-primary request_sample',
                request_idea_id: item.id,
                url: '#',
                name: 'Request Sample'
              }) + '<br>' +
              action_template({
                product_class: 'glyphicon glyphicon-question-sign sample_cost',
                request_idea_id: item.id,
                url: '#',
                name: ''
              });

              if (item.state == 'complete') {
                request_sample = 'Sample Requested'
              }

              start_auction = action_template({
                product_class: 'btn-success start_auction',
                request_idea_id: item.id,
                url: '/auctions/new?product_id='+item.product_variant.id+'&request_idea_id='+item.id,
                name: 'Start Auction'
              });

              if (item.auction_id) {
                start_auction = action_template({
                  product_class: 'btn-primary auction_started',
                  request_idea_id: item.id,
                  url: 'auctions/'+item.auction_id,
                  name: 'Auction Started'
                });
              }

              delete_idea = action_template({
                product_class: 'btn-danger delete_idea',
                request_idea_id: item.id,
                url: '#',
                name: 'Delete Idea'
              });

              trHTML += image_template({
                url: 'products/'+item.product_variant.slug,
                name: item.name,
                image: item.image_uri,
                value: item.product_variant.name
              });

              trHTML += simple_template({
                value: request_sample
              });

              trHTML += simple_template({
                value: start_auction
              });

              trHTML += simple_template({
                value: delete_idea
              });

              trHTML += "</tr>";
            });
          } else {
            trHTML += "<tr><td class='text-center' colspan='4'>if you have submitted a request to have a PromoExchange rep come up with product suggestions, you should expect those suggestions to be displayed here within the next couple of days.</td></tr>";
          }

          $this.find('span').removeClass('glyphicon-chevron-right').addClass('glyphicon-chevron-down')
          $this.parent().find('table').show();
          $this.parent().find(".idea-listing tbody").html(trHTML);
        }

      });
    }

  });

  $('tbody').on('click', '.sample_cost', function(){
    $('#request-sample-modal').modal('show');
  });

  $('tbody').on('click', 'a.delete_idea', function(e) {
    $(this).closest('tr').addClass('mfd');
    var request_idea_id = $(this).data('id');
    var key = $('#buyer-product-ideas-table').attr('data-key');
    var url = '/api/request_ideas/' + request_idea_id;
    var accept = confirm("Are you sure, you want to Delete Idea");
    if (!accept){ return false; }
    $.ajax({
      type: 'DELETE',
      data: {
        format: 'json'
      },
      url: url,
      headers: {
        'X-Spree-Token': key
      },
      statusCode: {
        200: function() {
          $('.mfd').fadeOut(400, function() {
            $(this).remove();
            alert('Delete Idea');
          });
        }
      }
    });
    return false;
  });

  $('tbody').on('click', '.request_sample', function(){
    var request_idea_id = $(this).data('id');
    var key = $('#buyer-product-ideas-table').attr('data-key');
    var url = '/api/request_ideas/' + request_idea_id + '/sample_request';
    var accept = confirm("Are you sure, you want to send sample request");
    if (!accept){ return false; }
    $.ajax({
      type: 'POST',
      contentType: "application/json",
      url: url,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        $('#product-ideas-tab').click();
        alert('Send Sample Request');
      },
      error: function(data) {
        alert('Failed to confirm order, please contact support');
      }
    });
  });

});

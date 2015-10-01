$(function() {
  $('tbody').on('click', '.track_shipment', function(){
    var auction_id = $(this).data('id');
    var key = $('.table').attr('data-key');
    var url = '/api/auctions/' + auction_id + '/tracking_information';
    var simple_template = _.template("<li>${name} at ${city}, ${country} on ${time}. ${message} </li>");
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
        $('#tracking-information').show('modal');
        var trHTML = '';
        if (data.length > 0){
          $.each(data, function(i, item) {
            var date = new Date(item.time);
            var options = {
                  year: "numeric", month: "long",
                  day: "numeric", hour: "2-digit", minute: "2-digit"
                };
            trHTML += "<ul>";
            trHTML += simple_template({
              name: item.name,
              city: item.location.city,
              country: item.location.province,
              time: date.toLocaleTimeString("en-us", options),
              message: item.message
            });
            trHTML += "</ul>";
          });
        } else {
          trHTML = 'Tracking information not available';
        }
        $("#tracking-information-view").html(trHTML);
      },
      error: function(data) {
        alert('Failed to get tracking information, please contact support');
      }
    });
  });

  $('#tracking-information-close').click(function(){
    $('#tracking-information').hide('modal');
  });
});

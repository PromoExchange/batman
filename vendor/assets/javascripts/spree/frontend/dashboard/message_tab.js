$(function() {
  $('#message-tab').click(function(e) {
    $("#message-table > tbody").html("<tr><td class='text-center' colspan='4'><i class='fa fa-spinner fa-pulse fa-3x'></i></td></tr>");
    var key = $("#message-table").attr("data-id");
    $.ajax({
      type: 'GET',
      data: {
        format: 'json'
      },
      url: '/api/messages',
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        var trHTML = '';
        if (data.length > 0) {
          $.each(data, function(i, item) {
            var crate = new Date(item.created_at);
            trHTML += "<tr><td><input type='checkbox'></td>";
            trHTML += "<td>" + crate.toLocaleString() + "</td>";
            trHTML += "<td>" + item.subject + "</td>";
            trHTML += "<td><i class='fa fa-trash'></i></td></tr>";
          });
        } else {
          trHTML += "<tr><td class='text-center' colspan='4'>No messages found!</td></tr>";
        }
        $("#message-table > tbody").html(trHTML);
      }
    });
    $(this).tab('show');
    return false;
  });
});

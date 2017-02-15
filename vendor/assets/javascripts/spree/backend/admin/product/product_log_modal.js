$(function() {
  $(".log-button").click( function(event) {
    var log = $(this).data('log');
    $("#log-modal-content").empty();
    if( typeof log != "undefined" ) {
      $("#log-modal-content")
        .append(
          $('<ul>')
            .addClass('log-list')
            .append(
              log.map( function(line) {
                return $('<li>').text(line);
              })
            )
        );      
      $('#log-modal').modal('show');
    } else {
      alert("No log messages found");
    }
  });
});

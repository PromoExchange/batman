$(function() {
  $(".log-button").click(function() {
    $("#log-modal-content")
      .empty()
      .append(
        $('<ul>')
          .addClass('log-list')
          .append(
            $(this).data('log').map( line => $('<li>').text(line) )
          )
      );
    $('#log-modal').modal('show');
  });
});

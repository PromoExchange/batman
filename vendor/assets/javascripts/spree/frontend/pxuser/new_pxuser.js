$(function() {
  $("#read-agreement-check-buyer").click(function() {
    if( this.checked ) {
      $("#pxuser_submit-buyer").prop('disabled', false);
    } else {
      $("#pxuser_submit-buyer").prop('disabled', true);
    }
  });

  $("#read-agreement-check-seller").click(function() {
    if( this.checked ) {
      $("#pxuser_submit-seller").prop('disabled', false);
    } else {
      $("#pxuser_submit-seller").prop('disabled', true);
    }
  });

  $(document).ready(function() {
    val = $('#pxuser_state').attr("data-value");

    if(val !== '') {
      $('#pxuser_state > option').each(function() {
        if( this.value == val ) {
          $(this).prop('selected', true);
          return false;
        }
      });
    }
  });
});

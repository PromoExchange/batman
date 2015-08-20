$(function() {
  $("#auction_logo_id").imagepicker({
    hide_select: false
  });

  $('.swatch-clickable').each(function() {
    $(this).attr('title', $(this).attr('name'));
  });

  $('.swatch-clickable').tooltip();

  $('#pms-colors').tagsinput({
    itemValue: 'id',
    itemText: 'text',
    maxTags: 2,
    freeInput: false
  });

  $(".swatch-clickable").click(function() {
    $('#pms-colors').tagsinput('add', {
      id: $(this).attr('id'),
      text: $(this).attr('name')
    });
  });
});

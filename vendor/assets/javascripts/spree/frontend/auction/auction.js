$(function(){
  $(".image-picker").imagepicker();

  // Bootstrap swatch picker
  // Alex Standke
  // 1 October 2013

  $('.swatch-clickable').each(function () {
      $(this).attr('title', $(this).attr('name'));
  });
  $('.swatch-clickable').tooltip();

  $('#pms-tags').tagsinput({
    itemValue: 'id',
    itemText: 'text',
    maxTags: 2
  });

  $(".swatch-clickable").click(function() {
    $('#pms-tags').tagsinput('add', { id: $(this).attr('id'), text: $(this).attr('name') });
  });
});

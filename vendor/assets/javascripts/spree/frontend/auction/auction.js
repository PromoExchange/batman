$(function(){
  $(".image-picker").imagepicker();
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

$(function() {
  $(document).ready(function() {
    $('[data-toggle="tooltip"]').tooltip();
  });

  $('.logo-upload').change(function() {
    readURL(this);
  });

  function readURL(input) {
    if (input.files && input.files[0]) {
      var reader = new FileReader();
      reader.onload = function(e) {
        $('.logo-to-upload').attr('src', e.target.result).removeClass('hidden');
      }
      reader.readAsDataURL(input.files[0]);
    }
  }

  var selectImage = function(imageId, src) {
    $('.main-product-image').attr('src', src);
    $('#purchase_image_id').attr('value', imageId);
  }

  $('#purchase_quality_option').change(function() {
    var quality_option = $("#purchase_quality_option").val();
    var categoryId = $('#purchase_category_id').val();
    var url = "/purchases/new?purchase[category_id]=" + categoryId + "&purchase[quality]=" + quality_option;
    window.location.href = url;
  });
});

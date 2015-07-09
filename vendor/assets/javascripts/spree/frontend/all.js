// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require spree/frontend

//= require_tree .
//= require spree/frontend/spree_first_data_gge4
//= require local_time
//= require image-picker/image-picker/image-picker.min
//= require bootstrap-tagsinput/dist/bootstrap-tagsinput.min
//= require lodash/lodash.min

$(function() {
  $('.title').on('keyup change', function(e) {
    var qty = parseInt($(this).val());
    if (allPrices === undefined || allPrices.length === 0) { return null; }

    if (qty <= allPrices.length) {
      $('span.price.selling').text('$' + allPrices[qty - 1]);
    } else {
      $('span.price.selling').text('$' + lowestDiscountedVolumePrice);
    }
  });
});

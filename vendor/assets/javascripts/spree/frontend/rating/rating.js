$(function() {
  $('.rating').rating({
    extendSymbol: function () {
      var title;
      $(this).tooltip({
        container: 'body',
        placement: 'bottom',
        trigger: 'manual',
        title: function () {
          return title;
        }
      });
      $(this).on('rating.rateenter', function (e, rate) {
        title = rate;
        $(this).tooltip('show');
      })
      .on('rating.rateleave', function () {
        $(this).tooltip('hide');
      });
    }
  });
})

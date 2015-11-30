$(function() {

  $('#favorite-items-tab').click(function() {
    window.history.pushState({}, null, '/dashboards?tab=favorite_items');
  });

  $('#support-tab').click(function() {
    window.history.pushState({}, null, '/dashboards?tab=support');
  });
  
});

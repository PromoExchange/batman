$(function() {

  $('#account-setting-tab').click(function() {
    window.history.pushState({}, null, '/dashboards?tab=account_setting');
  });
  
  
  $('#payment-method').click(function(e) {
    window.history.pushState({}, null, '/dashboards?tab=payment_method');
    
  });

  $('#address').click(function(e) {
    window.history.pushState({}, null, '/dashboards?tab=address');
   
  });
  
  $('#logo-click').click(function(e) {
    window.history.pushState({}, null, '/dashboards?tab=logo');
  });
  
  $('#taxrates').click(function(e) {
    window.history.pushState({}, null, '/dashboards?tab=taxrates');
  });
  
  $('#prebids').click(function(e) {
    window.history.pushState({}, null, '/dashboards?tab=prebids');
  });
  
  
  if ($($('#payment-method').parent()[0]).hasClass('active')) {
    $('#payment-method-tab').trigger('click');
  }
  
  if ($($('#address').parent()[0]).hasClass('active')) {
    $('#address-tab').trigger('click');
  }
  
  if ($($('#logo-click').parent()[0]).hasClass('active')) {
    $('#logo-click').trigger('click');
  }
  
  if ($($('#prebids').parent()[0]).hasClass('active')) {
    $('#prebids').trigger('click');
  }
  
   if ($($('#taxrates').parent()[0]).hasClass('active')) {
    $('#taxrates').trigger('click');
  }
 
});

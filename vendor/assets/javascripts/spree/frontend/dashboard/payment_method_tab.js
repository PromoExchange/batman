$(function() {

  $('#add-account').on('click', '.add-account', function() {
    $('#ach-cc-field').show();
  });

  $('#add-card').click(function() {
    $('#add-card-field').show();
  });

  $('.cancel-account').click(function() {
    $('#ach-cc-field').hide();
    $("#add-account button").prop('disabled', false).addClass('add-account');
  });

  $('.cancel-card').click(function() {
    $('#add-card-field').hide();
  });

  $('tbody').on('click', '.remove-customer', function() {
    var $this = $(this);
    var customer_id = $this.data('id');
    var key = $('#customer-method').attr('data-key');
    var accept = confirm("Are you sure you want to remove this account?");
    if (!accept){ return false; }
    $("body").css("cursor", "progress");
    $.ajax({
      type: 'POST',
      contentType: "application/json",
      url: '/delete_customer/'+customer_id,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        $this.parents('tr').hide('slow', function() {
          $(this).remove();
          $("body").css("cursor", "default");
        });
        $this.parents('tr').next('tr.confirm_tr').remove();
      },
      error: function(data) {
        alert("Unsuccessful delete");
      }
    });
  });

  function stripeResponseHandlerCustomer(status, response) {
    var $form = $('#customer-form');
    var key = $('#customer-method').attr('data-key');

    if (response.error) {
      $form.find('.payment-errors').text(response.error.message);
      $("body").css("cursor", "default");
      $("#payment-submit").prop('disabled', false);
    } else {
      var token = response.id;

      var message = {
        token: token,
        payment_type: 'cc'
      };

      $.ajax({
        type: 'POST',
        contentType: "application/json",
        data: JSON.stringify(message),
        url: '/customer',
        headers: {
          'X-Spree-Token': key
        },
        success: function(data) {
          $('#customer-form')[0].reset();
          alert('Save Credit/Debit card detail');
          window.location.href = "/dashboards?tab=payment_method";
        },
        error: function(data) {
          $form.find('.payment-errors').text("Unsuccessful create");
          $("body").css("cursor", "default");
          $("#payment-submit").prop('disabled', false);
        }
      });
    }
  }

  $('#customer-form').submit(function(event) {
    var $form = $(this);
    $("body").css("cursor", "progress");
    $("#payment-submit").prop('disabled', true);
    Stripe.card.createToken($form, stripeResponseHandlerCustomer);
    return false;
  });

  function stripeResponseHandlerAchCC(status, response) {
    var $form = $('#ach-cc-form');
    var key = $('#customer-method').attr('data-key');
    var cc_chek = document.getElementById("cc_checked").checked;
    if (response.error) {
      $form.find('.payment-errors').text(response.error.message);
      $("body").css("cursor", "default");
      $("#ach-cc-submit").prop('disabled', false);
    } else {
      if (cc_chek) { 
        var token = response.id;
        var message = {
          token: token,
          payment_type: 'cc',
          active_cc: cc_chek
        };

        $.ajax({
          type: 'POST',
          contentType: "application/json",
          data: JSON.stringify(message),
          url: '/customer',
          headers: {
            'X-Spree-Token': key
          },
          success: function(data) {
            $('#customer-form')[0].reset();
            alert('Save Credit/Debit card detail');
            $('#add-account-field').show();
            $('#ach-cc-field').hide();
            $("body").css("cursor", "default");
          },
          error: function(data) {
            $form.find('.payment-errors').text("Unsuccessful create");
            $("body").css("cursor", "default");
            $("#ach-cc-submit").prop('disabled', false);
          }
        });
      } else {
        $form.find('.payment-errors').text("Check box must be marked");
        $("body").css("cursor", "default");
        $("#ach-cc-submit").prop('disabled', false); 
      }
    }
  }

  $('#ach-cc-form').submit(function(event) {
    var $form = $(this);
    $("body").css("cursor", "progress");
    $("#ach-cc-submit").prop('disabled', true);
    $("#add-account button").prop('disabled', true).removeClass('add-account');
    Stripe.card.createToken($form, stripeResponseHandlerAchCC);
    return false;
  });

  function stripeResponseHandlerAccount(status, response) {
    var $form = $('#account-form');
    var nick_name = $form.find('.nick_name').val();

    if (!nick_name) {
      $form.find('.payment-errors').text('Nickname is blank');
    }
    else if (response.error) {
      $form.find('.payment-errors').text(response.error.message);
    } else {
      var token = response.id;

      $('.account_token').val(token);
      $('#add-account-field').hide();
      $('#confirm-account-field').show();
    }
    $("body").css("cursor", "default");
    $("#account-submit").prop('disabled', false);
  }

  $('#account-form').submit(function(event) {
    var $form = $(this);
    $("body").css("cursor", "progress");
    $("#account-submit").prop('disabled', true);
    $("#add-account button").prop('disabled', true).removeClass('add-account');
    Stripe.bankAccount.createToken($form, stripeResponseHandlerAccount);
    return false;
  });

  $('#confirm-submit').click(function() {
    $("body").css("cursor", "progress");
    $("#confirm-submit").prop('disabled', true);
    var key = $('#customer-method').attr('data-key');
    var token = $('.account_token').val();
    var nick_name = $('.nick_name').val();
    var account_number = $('.account_number').val();
    var confirm_number = $('.confirm_number').val();

    var message = {
      token: token,
      nick_name: nick_name,
      payment_type: 'wc'
    };

    if (confirm_number == account_number) {
      $.ajax({
        type: 'POST',
        contentType: "application/json",
        data: JSON.stringify(message),
        url: '/customer',
        headers: {
          'X-Spree-Token': key
        },
        success: function(data) {
          alert('Save bank account detail');
          $("#confirm_deposit .customer_id").val(data.id);
          $("#confirm_deposit").show();
          $('#confirm-account-field').hide();
          $('#confirm-account-field').hide();
          $('#account-form')[0].reset();
          $("body").css("cursor", "default");
        },
        error: function(data) {
          alert("Unsuccessful create");
          $("body").css("cursor", "default");
          $("#confirm-submit").prop('disabled', false);
        }
      });
      $('#account-form').find('.payment-errors').text("");
    } else {
      $('#account-form').find('.payment-errors').text("Account numbers did not match");
      $('#add-account-field').show();
      $('.confirm_number').val('');
      $("#confirm-submit").prop('disabled', false);
      $('#confirm-account-field').hide();
      $('#account-form')[0].reset();
      $("body").css("cursor", "default");
    }
  });

  $('tbody').on('click', '.amount-submit', function() {
    $("body").css("cursor", "progress");
    $(this).prop('disabled', true);
    var $this = $(this).parents('div.deposit-field');
    var key = $('#customer-method').attr('data-key');
    var customer_id = $this.find('.customer_id').val();
    var amount_first = $this.find('.amount_first').val();
    var amount_second = $this.find('.amount_second').val();

    var message = {
      customer_id: customer_id,
      amount_first: amount_first,
      amount_second: amount_second
    };

    $.ajax({
      type: 'POST',
      contentType: "application/json",
      data: JSON.stringify(message),
      url: '/confirm',
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        if (data.error) {
          error_msg = data.error.message;
          if(error_msg == 'Array must contain only valid integer_strings') {
            error_msg = 'Enter only the number of cents (e.g. 42 = $0.42)';
          }
          $this.find('.payment-errors').text(error_msg);
          $("body").css("cursor", "default");
          $(".amount-submit").prop('disabled', false);
        } else {
          alert('Confirm Account');
          window.location.href = "/dashboards?tab=payment_method";
        }
      },
      error: function(data) {
        $this.find('.payment-errors').text("Unsuccessful create");
        $("body").css("cursor", "default");
        $(".amount-submit").prop('disabled', false);
      }
    });
  });
});

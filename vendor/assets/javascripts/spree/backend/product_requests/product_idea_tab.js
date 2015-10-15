$(function() {
  $('.product-request').hide();

  $('ul').on('click', '.add_product', function(){
    var $this = $(this).parent().parent();
    $this.next().toggle();
  });

  $('ul').on('click', '.create_idea' ,function(){
    var $this = $(this).parent().parent();
    var product_id = $this.find('#product_id').val();
    var sample_cost = $this.find('#sample_cost').val();
    var product_request_id = $this.find('#product_request_id').val();
    var url = '/admin/product_requests';
    var message = {
      id: product_request_id,
      product_id: product_id,
      cost: sample_cost
    };
    $.ajax({
      type: 'POST',
      contentType: "application/json",
      data: JSON.stringify(message),
      url: url,
      success: function(data) {
        console.log(data.error_msg)
        if (data.error_msg.length) {
          alert(data.error_msg);
        } else {
          alert('successfully create request idea.');
          window.location = "/admin/product_requests";
        }
      },
      error: function(data) {
        alert('Failed to add product');
      }
    });
  });

  $('ul').on('click', '.remove_idea', function(){
    var $this = $(this).parent().parent();
    var request_idea_id = $this.data('id');
    var url = '/product_requests/' + request_idea_id + '/destroy';
    var accept = confirm("Are you sure, you want to Delete Idea");
    if (!accept){ return false; }
    $.ajax({
      type: 'POST',
      contentType: "application/json",
      url: url,
      success: function(data) {
        $this.remove();
        alert('Delete Idea');
      },
      error: function(data) {
        alert('Failed to Delete Idea');
      }
    });
  });

  $('ul').on('click', '.generate-notification', function(){
    var $this = $(this).parent().parent();
    var product_request_id = $this.data('id');
    var url = '/admin/product_requests/' + product_request_id + '/generate_notification';
    $.ajax({
      type: 'POST',
      contentType: "application/json",
      url: url,
      success: function(data) {
        alert('successfully send email to buyer.');
        window.location = "/admin/product_requests";
      },
      error: function(data) {
        alert('Failed send email to buyer');
      }
    });
  });

  $('ul').on('click', '.edit-idea', function(){
    var $this = $(this).parent().parent();
    var sample_cost = $this.find('li.sample_cost').text();
    var input_cost = $('<input type="text" value="' + sample_cost + '" />');
    var update_button = $('<button name="button" type="submit" class="btn-success update-idea">Update</button>');

    $this.find('li.sample_cost').text('').append(input_cost);
    $this.find('li.action_button').html(update_button);
  });

  $('ul').on('click', '.update-idea', function(){
    var $this = $(this).parent().parent();
    var sample_cost = $this.find('li.sample_cost input').val();
    var request_idea_id = $this.data('id');
    var url = '/product_requests/' + request_idea_id + '/update';
    var message = {
      cost: sample_cost
    };
    $.ajax({
      type: 'POST',
      contentType: "application/json",
      data: JSON.stringify(message),
      url: url,
      success: function(data) {
        alert('successfully update request idea.');
        window.location = "/admin/product_requests";
      },
      error: function(data) {
        alert('Failed to update request idea');
      }
    });
  });

});
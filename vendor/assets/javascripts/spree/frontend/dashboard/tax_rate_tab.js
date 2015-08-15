$(function() {
  $('tbody').on('click', 'button.open-tax-rate', function(e) {
    $('#tax-rate-form')[0].reset();
    var row = $(this).closest('tr');
    var rate = row.find('td.rate-amount').html();
    var include_sandh = row.find("td.rate-includesandh").html();
    var taxrate_id = row.attr('data-id');
    $('#tax-rate-form > #taxrate-id').val(taxrate_id);
    $("#tax-rate-edit").val(rate);
    $("#include-sandh-edit").prop("checked", (include_sandh==='true'));
  });

  $('#tax-rate-submit').click(function(e){
    var key = $('#seller-live-auction-table').attr('data-key');
    var taxrate_id = $('#tax-rate-form > #taxrate-id').val();
    var taxrate_value = $("#tax-rate-edit").val();
    var taxrate_include = $("#include-sandh-edit").prop('checked');
    var taxrate_url = '/api/taxrates/' + taxrate_id;

    var message = {
      id: taxrate_id,
      amount: taxrate_value,
      include_in_sandh: taxrate_include
    };

    $.ajax({
      type: 'PUT',
      contentType: "application/json",
      data: JSON.stringify(message),
      url: taxrate_url,
      headers: {
        'X-Spree-Token': key
      },
      success: function(data) {
        var taxrate_cell_id = "#taxrate-" + taxrate_id + " > td.rate-amount";
        $(taxrate_cell_id).html(taxrate_value);

        var include_cell_id = "#taxrate-" + taxrate_id + " > td.rate-includesandh";
        if(taxrate_include === true) {
          $(include_cell_id).html('true');
        } else {
          $(include_cell_id).html('false');
        }
        alert('Tax rate updated');
      },
      error: function(data) {
        console.log(date);
        alert('Failed to update tax rate');
      }
    });
  });
});

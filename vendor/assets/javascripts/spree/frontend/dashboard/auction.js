$(function(){
  $('#auction-tab').click(function(e) {
      $("#live-auction-table > tbody").html("<tr><td class='text-center' colspan='4'><i class='fa fa-spinner fa-pulse fa-3x'></i></td></tr>");;
      var key = $("#live-auction-table").attr("data-id");
      $.ajax({
        type: 'GET',
        data:{
          format: 'json'
        },
        url: '/api/auctions',
        headers:{
          'X-Spree-Token': key
        },
        success: function(data){
          var trHTML = '';
          if( data.length > 0 ){
            $.each(data, function(i,item){
              var crate = new Date(item.created_at)
              trHTML += "<tr><td><input type='checkbox'></td>";
              trHTML += "<td>"+crate.toLocaleString()+"</td>";
              trHTML += "<td>"+item.subject+"</td>";
              trHTML += "<td><i class='fa fa-trash'></i></td>";

              trHTML += "<tr><td>"image_tag auction.image, { itemprop: "image", alt: auction.product.name } %><p><%= auction.product.name %></p></td>
              <td><%= auction.lowest_bid.seller.email if auction.lowest_bid %></td>
              <td><%= auction.quantity %></td>
              <td><%= local_time(auction.started, '%m/%d/%Y') if auction.started %></td>
              <td><%= local_time(auction.ended, '%m/%d/%Y') if auction.ended %></td>
              <td><ul>
                <li><%= link_to Spree.t(:cancel), main_app.auction_path(auction), method: :delete, :data => {:confirm => 'Are you sure?'}%></li>
              </ul></td>

            });
          }else{
            trHTML += "<tr><td class='text-center' colspan='4'>No messages found!</td></tr>";
          }
          $("#message-table > tbody").html(trHTML);
        }
      });
      $(this).tab('show');
      return false;
  });
});

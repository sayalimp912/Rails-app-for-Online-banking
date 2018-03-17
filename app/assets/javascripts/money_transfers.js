var MoneyTransfer = {

  acceptTransfer: function(transfer_id){
    var url = "/money_transfers/" + transfer_id;
    $.ajax({
      url: url,
      type: 'patch',
      dataType: 'json',
      success: function( data, status, xhr ) {
        if(data['error']) {
          alert(data['error']);
        } else {
          $('#' + data['transfer_id'] + '-td').html('Completed');
        }
      }
    });
  }

}
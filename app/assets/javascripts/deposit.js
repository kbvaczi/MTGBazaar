$(document).ready(function() {
  
  //UPDATE QUANTITY IN CART WHEN CHANGED
  $("#account_balance_transfer_balance").change(function() {
    var value = Number($(this).val().replace(/[^0-9\.]+/g,""));
    var commission = ((value / 0.971) + 0.30);
    $("#commission_statement").text("Total charge including Paypal's fee: $" + commission.toFixed(2));
  });
  
});
$(document).ready(function() {
  numericTrigger();  
});

function numericTrigger() {
  $(".numeric").numeric({ negative : false, decimal : false }); // do not allow negative values
}
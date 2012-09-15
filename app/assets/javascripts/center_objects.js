/* This script automatically centers objects with the class "center" */
/* This script automatically centers objects with the class "center" */
/* This script automatically centers objects with the class "center" */

$(document).ready(function() {

  $(".center").each(function(index) {  
    var margin_width = 0;
    
    margin_width = $(this).parent().width() / 2 - $(this).outerWidth() / 2
    /*$(this).css("margin-right", margin_width + "px");*/
    $(this).css("margin-left", margin_width + "px");
  });
  
});
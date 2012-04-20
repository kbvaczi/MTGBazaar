/* ACTIVATES CHOSEN SELECT BOXES */
$(document).ready(function() { 

  // Activates chosen select boxes with css tag .chzn-select
  $(".chzn-select").chosen();

  // Custom function which removes the chzn search bar for select boxes with .chzn-nosearch tag
  $(".chzn-nosearch").parent().find(".chzn-search").hide();
  
});



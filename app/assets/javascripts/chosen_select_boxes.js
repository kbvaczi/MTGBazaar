/* ACTIVATES CHOSEN SELECT BOXES */
$(document).ready(function() { 

  // Activates chosen select boxes with css tag .chzn-select
  // do this last so that other jquery scripts can update select inputs if necessary before turning htem into chosen boxes
  $(".chzn-select").chosen({allow_single_deselect: true, disable_search_threshold: 10, max_selected_options: 5});
  //$(".chzn-select").bind("liszt:maxselected", function () { alert("yelp"); });
  
});



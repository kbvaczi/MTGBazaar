/* ACTIVATES CHOSEN SELECT BOXES */
$(document).ready(function() { 
  
  $.activateChosenSelect();
  
});


$.activateChosenSelect = function(){

  // Activates chosen select boxes with css tag .chzn-select
  // do this last so that other jquery scripts can update select inputs if necessary before turning htem into chosen boxes
  $(".chzn-select").chosen({allow_single_deselect: true, disable_search_threshold: 10, max_selected_options: 5});
  $(".chzn-select-ajax").chosen({allow_single_deselect: true, disable_search_threshold: 0, max_selected_options: 5});  
  //$(".chzn-select").bind("liszt:maxselected", function () { alert("yelp"); });

  // Custom function which removes the chzn search bar for select boxes with .chzn-nosearch tag
  $(".chzn-nosearch").parent().find(".chzn-search").hide();

  // Prevent page scrolling wiht mousewheel when scrolling inside a chosen box
  $(".chzn-results").bind('mousewheel DOMMouseScroll', function(e) {
    var scrollTo = null;

    if(e.type == 'mousewheel') {
      scrollTo = (e.originalEvent.wheelDelta * -1);
    }
    else if (e.type == 'DOMMouseScroll') {
      scrollTo = 40 * e.originalEvent.detail;
    }

    if (scrollTo) {
      e.preventDefault();
      $(this).scrollTop(scrollTo + $(this).scrollTop());
    }
  });
  
/*  
  $(".chzn-select-ajax").ajaxChosen({
      type: 'GET',
      url: '/users/autocomplete_name_chosen.json',
      dataType: 'json'
  }, function (data) {
      var results = {};
      $.each(data, function (i, val) {
          results[i] = val;
      });

      return results;
  });

  $(".chzn-select-ajax").ajaxChosen({
      type: 'GET',
      dataType: 'json'
  }, function (data) {
      var results = {};
      $.each(data, function (i, val) {

          results[i] = { // here's a group object:
              group: true,
              text: val.name, // label for the group
              items: val["items"] // individual options within the group
          };
          $.each(val.values, function (i1, val1) {
              results[i].items[val1.Id] = val1.name;
          });
      });
      return results;
  });*/

}
/* This script automatically centers objects with the class "center" */
/* This script automatically centers objects with the class "center" */
/* This script automatically centers objects with the class "center" */

$(document).ready(function() {

  $(".center").centerHorizontal();
  
  $(".centerScreen").centerScreen();

});


(function($){
	$.fn.centerHorizontal = function(){
    $(this).each(function(index) {  
      var margin_width = 0;
      var this_width = 0;
      $(this).children().each(function(){
        this_width += $(this).outerWidth(true);
      });
      if(this_width == 0){
        this_width = $(this).outerWidth();
      }
      margin_width = $(this).parent().innerWidth() / 2 - this_width / 2
      $(this).css("margin-left", margin_width + "px");
    });
  }      
})(jQuery);

/*
$(".center").each(function(index) {  
  var margin_width = 0;
  var this_width = 0;
  $(this).children().each(function(){
    this_width += $(this).outerWidth(true);
  });
  if(this_width == 0){
    this_width = $(this).outerWidth();
  }
  margin_width = $(this).parent().innerWidth() / 2 - this_width / 2
  $(this).css("margin-left", margin_width + "px");
});*/
(function($){
  $.fn.centerScreen2 = function () {
    this.css("position","absolute");
    this.css("top", Math.max(0, (($(window).height() - this.outerHeight()) / 2) + 
                                                $(window).scrollTop()) + "px");
    this.css("left", Math.max(0, (($(window).width() - this.outerWidth()) / 2) + 
                                                $(window).scrollLeft()) + "px");
    return this;
  }
})(jQuery);



(function($){
     $.fn.extend({
          centerScreen: function (options) {
               var options =  $.extend({ // Default values
                    inside:window, // element, center into window
                    transition: 0, // millisecond, transition time
                    minX:0, // pixel, minimum left element value
                    minY:0, // pixel, minimum top element value
                    vertical:true, // booleen, center vertical
                    withScrolling:true, // booleen, take care of element inside scrollTop when minX < 0 and window is small or when window is big 
                    horizontal:true // booleen, center horizontal
               }, options);
               return this.each(function() {
                    var props = {position:'absolute'};
                    if (options.vertical) {
                         var top = ($(options.inside).height() - $(this).outerHeight(true)) / 2;
                         if (options.withScrolling) top += $(options.inside).scrollTop() || 0;
                         top = (top > options.minY ? top : options.minY);
                         $.extend(props, {top: top+'px'});
                    }
                    if (options.horizontal) {
                          var left = ($(options.inside).width() - $(this).outerWidth(true)) / 2;
                          if (options.withScrolling) left += $(options.inside).scrollLeft() || 0;
                          left = (left > options.minX ? left : options.minX);
                          $.extend(props, {left: left+'px'});
                    }
                    if (options.transition > 0) $(this).animate(props, options.transition);
                    else $(this).css(props);
                    return $(this);
               });
          }
     });
})(jQuery);
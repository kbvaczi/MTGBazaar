$(document).ready(function() {
  
  $(".overlay_trigger[rel]").overlay({mask:'#000'});
  

      // if the function argument is given to overlay,
      // it is assumed to be the onBeforeLoad event listener
      $("a[rel]").overlay({

          mask: '#000',

          onBeforeLoad: function() {

              // grab wrapper element inside content
              var wrap = this.getOverlay().find(".contentWrap");

              // load the page specified in the trigger
              wrap.load(this.getTrigger().attr("href"));
          }

      });

  
  $(".tooltip_trigger[title]").tooltip();
  
});
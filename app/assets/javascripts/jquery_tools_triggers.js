$(document).ready(function() {
  
//  $(".overlay_trigger[rel]").overlay({mask:'#000'});
  
  //creates overlay appended to body of page to avoid centering conflicts... then runs centerScreen to center object.
  $(".overlay_trigger[rel]").overlay({
    mask:'#000',
    onBeforeLoad: function() {
      this.getOverlay().appendTo('body').centerScreen();
    }
  });
  
  
  initialize_tooltips();
  
});

function initialize_tooltips() {
  
  $("[title]").tooltip({ 
    position: { 
      my: "left bottom", 
      at: "right+5 top", 
      collision: "flipfit" 
    },
    show: false,
    hide: false
  });  
  
}
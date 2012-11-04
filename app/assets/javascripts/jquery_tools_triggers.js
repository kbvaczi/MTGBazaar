$(document).ready(function() {
  
//  $(".overlay_trigger[rel]").overlay({mask:'#000'});
  
  //creates overlay appended to body of page to avoid centering conflicts... then runs centerScreen to center object.
  $(".overlay_trigger[rel]").overlay({
    mask:'#000',
    onBeforeLoad: function() {
      this.getOverlay().appendTo('body').centerScreen();
    }
  });
  
  $(".tooltip_trigger[title]").tooltip();
  
});
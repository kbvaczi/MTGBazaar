$(document).ready(function() {
  
//  $(".overlay_trigger[rel]").overlay({mask:'#000'});
  
  $(".overlay_trigger[rel]").overlay({
    mask:'#000',
    onBeforeLoad: function() {
      this.getOverlay().appendTo('#main');
    }
  });
  
  $(".tooltip_trigger[title]").tooltip();
  
});
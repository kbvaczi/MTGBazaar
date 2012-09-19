$(document).ready(function() {
  
//  $(".overlay_trigger[rel]").overlay({mask:'#000'});
  
  $(".overlay_trigger[rel]").overlay({
    mask:'#000',
    onBeforeLoad: function() {
        this.getOverlay().appendTo('#center_bar');
    }
  });
  
  $(".tooltip_trigger[title]").tooltip();
  
});
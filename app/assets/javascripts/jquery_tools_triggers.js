$(document).ready(function() {
  
  initialize_overlays();
  initialize_tooltips();
  
});

function initialize_overlays() {
  //creates overlay appended to body of page to avoid centering conflicts... then runs centerScreen to center object.
  $(".overlay_trigger[rel]").overlay({
    mask:'#000',
    onBeforeLoad: function() {
      this.getOverlay().appendTo('body').centerScreen();
    }
  });
}


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
  
  $("img.mtg_teaser_image").tooltip({
    items: "img",
    content: "<div class=\'mtg_teaser_image_tooltip\'> </div>",
    open: function( event, ui ) {
      var element = $( this );
      var src = element.attr("src").replace("_thumb.jpg", ".jpg");
      element.tooltip('option', 'content', '<div class=\'mtg_teaser_image_tooltip\'><img class="mtg_teaser_image_tooltip_image" src=' + src + '></div>');
    },
    position: { 
      my: "left bottom", 
      at: "right+15 bottom",
      collision: "fit"
    },
    show: false,
    hide: false
  });
  
}
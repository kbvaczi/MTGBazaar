$(document).ready(function() {

  var opts = {
    lines: 10, // The number of lines to draw
    length: 7, // The length of each line
    width: 8, // The line thickness
    radius: 20, // The radius of the inner circle
    corners: 1, // Corner roundness (0..1)
    rotate: 0, // The rotation offset
    color: '#000', // #rgb or #rrggbb
    speed: 1, // Rounds per second
    trail: 60, // Afterglow percentage
    shadow: true, // Whether to render a shadow
    hwaccel: true, // Whether to use hardware acceleration
    className: 'spinner', // The CSS class to assign to the spinner
    zIndex: 2e9, // The z-index (defaults to 2000000000)
    top: 'auto', // Top position relative to parent in px
    left: 'auto' // Left position relative to parent in px
  };

  $('#main').bind('ajaxStart', function(){
      $(this).spin(opts);
      $('.spinner').css({
        display:'none',
        position:'fixed',
        top:'35%',
        left:'49%',
        width:'50px',                 // adjust width
        height:'50px',                // adjust height
        zIndex:99999,
        marginTop:'0px',             // half of height
        marginLeft:'0px'            // half of width
      });
      $('.spinner').delay(1500).fadeIn();
  }).bind('ajaxStop', function(){
      $('.spinner').stop(1);
      $(this).spin(false);
  });
        
});

$.fn.spin = function(opts) {
  this.each(function() {
    var $this = $(this),
        data = $this.data();

    if (data.spinner) {
      data.spinner.stop();
      delete data.spinner;
    }
    if (opts !== false) {
      data.spinner = new Spinner($.extend({color: $this.css('color')}, opts)).spin(this);
    }
  });
  return this;
};
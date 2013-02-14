$(document).ready(function() {
  showFlash();
});

function flashNow(message, type) {
  var flash ="<div id='flash' class='flash_" + type + "' style='display: none;'>" + message + "<div class='closeButton right'>X</div></div>";
  $('#flash').remove();
  $('body').prepend(flash);
  $('#flash').fadeIn('normal', function() {
    $(this).delay(6000).fadeOut();
  });
}

function showFlash() {
  if ( $('#flash').length ) {
    var closeButton = '<div class="closeButton right">X</div>';
    $(closeButton).appendTo($('#flash'));
    $('#flash').delay(30).fadeIn('normal', function() {
      $(this).delay(6000).fadeOut();
    });
  }
  $('#flash').click(function(e) {
    $(this).hide();
  });  
}
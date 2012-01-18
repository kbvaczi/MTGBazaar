$(document).ready(function() {

  $(function() {
    if ( $('#flash').length ) {
      var closeButton = '<div class="closeButton right">X</div>';
      $(closeButton).appendTo($('#flash'));
      $('#flash').delay(30).fadeIn('normal', function() {
        $(this).delay(6000).fadeOut();
      });
    }
  });
  $('#flash').click(function(e) {
    $(this).hide();
  });

});
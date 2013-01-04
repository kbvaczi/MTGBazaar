$(document).ready(function() {
	
	$('#slider_right_bar2').bxSlider({
    auto:        true,
    autoHover:   true,
    mode:        'fade',  
		pause:       7000,
		controls:    false,
		randomStart: true,
		pager:       false,
    slideWidth:  '230px'
  });
	  
	$('#slider_right_bar_3').bxSlider({
    useCSS:      false,
    auto:        true,
    mode:        'fade',      
    autoHover:   true, 
		pause:       9000,
		controls:    true,
		randomStart: true,
		pager:       false, 
    slideWidth:  '230px'
  });

});


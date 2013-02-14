$(document).ready(function() {
	
	$('#slider_news_bar').bxSlider({
    useCSS:      false,	  
    auto:        true,
    autoHover:   true,
		pause:       6000,
    mode:        'fade',  
		controls:    false,
		randomStart: true,
		pager:       true,
    slideWidth:  540
  });
	
	$('#slider_right_bar2').bxSlider({
    useCSS:      false,	  
    auto:        true,
    autoHover:   true,
    mode:        'fade',  
		pause:       9000,
		controls:    false,
		randomStart: true,
		pager:       false,
    slideWidth:  230
  });
	  
	$('#slider_right_bar_3').bxSlider({
    useCSS:      false,
    auto:        true,
    autoHover:   true, 
		pause:       5000,
    mode:        'fade',  		
		controls:    true,
		randomStart: true,
		pager:       false, 
    slideWidth:  230
  });

});


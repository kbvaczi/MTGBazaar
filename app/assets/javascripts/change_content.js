$('html').addClass('js');

$(function() {
    var $divs = $('div', '#container'),
        all$divs = $.map($divs, function(div) {return $(div);});
        total = $divs.length,
        counter = 0,
 
        showDiv = function() {
            $divs.stop().hide();
            all$divs[counter].show();
            counter = (counter + 1) % total;
            setTimeout(showDiv, 10000);
        };
    $divs.hide();
    showDiv();
});
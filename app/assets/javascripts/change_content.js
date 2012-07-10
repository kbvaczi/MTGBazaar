$('html').addClass('js');

$(function() {
    var $divs = $('div', '#container'),
        total = $divs.length,
        counter = 0,
 
        showDiv = function() {
            $divs.stop().hide();
            $($divs[counter]).show('fast');
            counter = (counter + 1) % total;
            setTimeout(showDiv, 10000);
        };
    $divs.hide();
    showDiv();
});
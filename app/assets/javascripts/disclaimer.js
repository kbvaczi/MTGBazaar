$(document).ready(function() {

            $(".AcknowledgeOuterDiv").scroll(function() {
                var outerDiv = $(this);
                var innerDiv = $(">.AcknowledgeInnerDiv", $(this));
                var ScrollMod = 1;
                if (outerDiv.offset().top < innerDiv.outerHeight()) {
                    ScrollMod = -1;
                }
                if ($(this)[0].scrollHeight - $(this).scrollTop() == $(this).outerHeight()) {
                    $("#AcknowledgeCheckBox").attr("disabled", false);
                    $(this).unbind("scroll");
                } else {
                    $("#AcknowledgeCheckBox").attr("disabled", true);
                }

            });

});


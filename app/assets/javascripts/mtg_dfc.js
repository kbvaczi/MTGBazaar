$(document).ready(function() {

  $(".dfc_day_icon").click(function() {  
    $(".card_info_wrapper_back").hide();          
    $(".card_info_wrapper").show();
  });
  
  $(".dfc_night_icon").click(function() {  
    $(".card_info_wrapper").hide();
    $(".card_info_wrapper_back").show();    
  });  
  
});
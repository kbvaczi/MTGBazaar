$(document).ready(function() {

  $(".dfc_day_icon").click(function() {  
    $(".card_info_wrapper_back").hide();          
    $(".card_info_wrapper").show();
  });
  
  $(".dfc_night_icon").click(function() {  
    $(".card_info_wrapper").hide();
    $(".card_info_wrapper_back").show();    
  });  
  
  $('.mtg_card_image').draggable( "disable" )
  $('.mtg_card_image_horizontal:hover').draggable( "disable" )  
  $('.mtg_card_image_horizontal:active').draggable( "disable" )    
  $('.card_info_wrapper').draggable( "disable" )   
  
});
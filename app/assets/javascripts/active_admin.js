//= require active_admin/base
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require autocomplete-rails
//= require_self
CKEDITOR_BASEPATH = "/assets/ckeditor/";


// This script enables submit button on mtg_cards XML file upload when a file is chosen so that you cannot submit with no file...
$(document).ready(function() {

  $("#upload_file").change(function() {  
    if ($("#upload_file").val() != "") {
      $('#submit_upload_file').removeAttr('disabled');
    }
  });
  
  
});
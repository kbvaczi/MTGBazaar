
$.rails.allowAction = function(element) {
        var message = element.data('confirm'),
        answer = false, callback;
        if (!message) { return true; }

        if ($.rails.fire(element, 'confirm')) {
                myCustomConfirmBox(message, function() {
                        callback = $.rails.fire(element,
                                'confirm:complete', [answer]);
                        if(callback) {
                                var oldAllowAction = $.rails.allowAction;
                                $.rails.allowAction = function() { return true; };
                                element.trigger('click');
                                $.rails.allowAction = oldAllowAction;
                        }
                });
        }
        return false;
}

function myCustomConfirmBox(message, callback) {
        // call callback() if the user says yes
        var dialogHtml = "<div id='dialog-confirm' title='Are you sure?'><p>" + message + "</p></div>"
        $('#dialog-confirm').remove();
        $('body').append(dialogHtml);
        
        $( "#dialog-confirm" ).dialog({
            resizable: true,
            height:'auto',
            modal: true,           
            buttons: {
                Yes: function() {
                    $( this ).dialog( "close" );
                    callback();
                },
                Cancel: function() {
                    $( this ).dialog( "close" );
                }
            }
        });
}

function myCustomAlertBox(message) {
  // call callback() if the user says yes
  var dialogHtml = "<div id='dialog-confirm' title='Attention'><p>" + message + "</p></div>"
  $('#dialog-confirm').remove();
  $('body').append(dialogHtml);
  $( "#dialog-confirm" ).dialog({
    title: 'Attention',
    resizable: false,
    height:'auto',
    stack:false,  
    modal: true,   
    buttons: {
      OK: function() {
        $( this ).dialog( "close" );
      }
    }
  });
}
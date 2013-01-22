function getImageInfo(card_name, set_code ){
  var value  = "";
  var params = [{ name:"card_name",  value: card_name },
                { name:"set_code",   value: set_code  }];
  var url    = "/ckeditor/get_image_path_from_card_and_set_name?" + $.param(params);
  $.ajax({
    type: "GET",
    url: url,
    dataType: "json",
    async: false,
    success : function(data) { value = data; }
  });
  return value;
}

function updateSets(){
  var params = [{ name:"card_name",  value: $('input[name=card_image_name_input]').val() }];
  var url    = "/ckeditor/get_available_sets_from_card_name?" + $.param(params);
  $.ajax({
    type: "GET",
    url: url,
    dataType: "json",
    async: false,
    success : function(data) { 
      if (data.length >= 1) {
        $(data).each(function(index, item) {
          target = $('select[name=card_image_set_input]');
           target.children().remove();
           target.append('<option value=' + item[1] + '>' + item[0] + '</option>');           
        });
      }
    }   
  });
}

function deleteSets(){
  target = $('select[name=card_image_set_input]');
  target.children('option[value]').remove();
}

CKEDITOR.dialog.add("inserthtml",function(e){	
	return{
		title:'insert a card image',
		resizable : CKEDITOR.DIALOG_RESIZE_BOTH,
		minWidth:300,
		minHeight:100,
		onLoad:function(){ 
			dialog = this; 
			this.setupContent();
		},
		onOk:function( data ){
			var card_name    = this.getValueOf('info','card_name_input');
			var image_height = this.getValueOf('info','image_size_select').split("x")[0];
			var image_width  = this.getValueOf('info','image_size_select').split("x")[1];
			var card_info    = getImageInfo(dialog.getValueOf('info','card_name_input'), dialog.getValueOf('info','set_select_input'))
		  var image_path   = card_info[0];
		  var card_link    = card_info[1];
			if ( image_path.length > 0 )
			e.insertHtml("<a href="+ card_link +" style=\"margin:2px;\"><img style='width:" + image_width + "px;height:" + image_height + "px;' src='" + image_path + "' title=\"" + card_name + "\" alt=\"" + card_name + "\"/></a>"); 
		},
		contents:[
			{	id:"info",
				name:'info',
				label:'Info',
				elements:[{	type:'vbox',
          				  padding:'10',
            				children:[{ type:'html',
				                        id: 'card_name_input',
				                        html: "<input class='ui-autocomplete-input' name='card_image_name_input' style='width:200px;background:#fff;' data-autocomplete='/mtg/cards/autocomplete_name' data-type='search' placeholder='Card Name...' type='text' autocomplete='off' onblur=\"updateSets();\" onkeypress='deleteSets();'>",
				                      },
				                      { type:'html',
  			                        id: 'set_select_input',
  			                        html: "<select class='select required' name='card_image_set_input' required='required'><options><option>Select A Set...</option></options>",
  			                        validate : CKEDITOR.dialog.validate.notEmpty("set cannot be empty")
  			                      },
				                      { type: 'select',
                                id: 'image_size_select',
                                label: 'Image Size',
                                items: [ [ 'Small', ['118x85'] ], [ 'Medium', ['159x115'] ], [ 'Large', ['236x170'] ] ],
                                'default': ['159x115']
                               }]
				}]
			}
		]
	};
});
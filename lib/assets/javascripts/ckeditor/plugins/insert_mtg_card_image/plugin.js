CKEDITOR.plugins.add('insert_mtg_card_image', {    
  requires: ['dialog'],
  init:function(a) { 
    var b="insert_card";
	  var c=a.addCommand(b,new CKEDITOR.dialogCommand(b));
		c.modes={wysiwyg:1,source:0};
		c.canUndo=false;
	  a.ui.addButton("insert_mtg_card_image", {
			label:'Add Card Image',
      icon: 'https://mtgbazaar.s3.amazonaws.com/images/icons/ckeditor/icon_card_insert.png',
			command:b
  	});
  	CKEDITOR.dialog.add(b, this.path + "dialogs/insert_card_image.js");
	}
});
CKEDITOR.plugins.add('insert_mtg_decklist', {    
  requires: ['dialog'],
  init:function(a) { 
    var b     = "insert_mtg_decklist";
	  var c     = a.addCommand(b, new CKEDITOR.dialogCommand(b));
		c.modes   = { wysiwyg:1, source:0 };
		c.canUndo = false;
	  a.ui.addButton("insert_mtg_decklist", {
			label:   'Add MTG Decklist',
      icon:    '',
			command: b
  	});
  	CKEDITOR.dialog.add(b, this.path + "dialog.js");
	}
});
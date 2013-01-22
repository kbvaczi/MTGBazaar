/*********************************************************************************************************/
/**
 * inserthtml plugin for CKEditor 3.x (Author: Lajox ; Email: lajox@19www.com)
 * version:	 1.0
 * Released: On 2009-12-11
 * Download: http://code.google.com/p/lajox
 */
/*********************************************************************************************************/

CKEDITOR.plugins.add('inserthtml',   
  {    
    requires: ['dialog'],
	lang : ['en'], 
    init:function(a) { 
	var b="inserthtml";
	var c=a.addCommand(b,new CKEDITOR.dialogCommand(b));
		c.modes={wysiwyg:1,source:0};
		c.canUndo=false;
	a.ui.addButton("inserthtml",{
					label:'Add Card Image',
					text:'add card',
					command:b
	});
	CKEDITOR.dialog.add(b,this.path+"dialogs/inserthtml.js")}
});
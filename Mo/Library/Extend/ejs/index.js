/*
** File: view_ejs.js
** Usage: parse template to jscript codes.
** About: 
**		support@mae.im
*/
var Ejs = require("./ejs.js");
var EJS = {
	compile : function(content){
		var tpl = new Ejs({text : content});
		var template =  tpl.template.out
		.replace(/___ViewO\.push\("(.*?)"\)/ig,"_contents += \"$1\"")
		.replace(/EJS\.Scanner\.to_text/ig,"")
		.replace(/___ViewO\.push/ig,"_echo")
		.replace(/_echo\(\(\((.+?)\)\)\);/ig,"_echo($1);")
		.replace(/";(\s+?)_contents \+\= "/igm,"");
		tpl = null;
		
		template = "if(typeof Mo==\"undefined\"){Response.Write(\"invalid call.\");Response.End();}" + 
		"\r\nfunction _echo(src){if(src===undefined || src===null) src=\"\";_contents += src;if(!__buffer && _contents.length>__buffersize) {Response.Write(_contents);_contents=\"\";}}" +
		"\r\nfunction _end(){if(!__buffer)Response.Write(_contents);}\r\nvar _contents = \"\";" +
		"\r\n\"UNSAFECONTENTS\";\r\nwith($){\r\n" + template + 
		"\r\n}\r\n_end();delete _end;delete _echo;if(__buffer) return _contents;";
		
		return template;
	}
};
module.exports = EJS;
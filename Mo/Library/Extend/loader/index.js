/*
loader
*/

function Gzip(content){
	if(typeof content == "string"){
		return GzipBuffer(Utf8.getBytes(content));
	}else{
		return GzipBuffer(content);
	}
}
function GzipBuffer(content){
	var gzip = require("gzip/deflate");
	return Base64.toBinary(Base64.e(gzip.deflate(content,{gzip:true})));
}

module.exports = function(files){
	var type = "css", isgzip = true;
	if(!/^([\w\/\.\-\_\;]+)$/igm.test(files)) return;
	if(files.slice(-3).toLowerCase()==".js") type = "js";
	if(files.slice(-5).toLowerCase()==".woff") type = "woff";
	if(files.slice(-6).toLowerCase()==".woff2") type = "woff2";
	files = files.replace(/\.(js|css|woff|woff2)$/ig,"");
	if(F.server("HTTP_ACCEPT_ENCODING").indexOf("gzip")<0) isgzip=false;
	if(type=="woff" || type=="woff2"){
		Response.ContentType="application/x-font-woff";
	}else{
		Response.ContentType="text/" + type.replace("js","javascript");
	}

	if(isgzip){
		var etag = Crc32(files), gizcachefile = F.mappath(Mo.Config.Global.MO_APP + "Cache/Gzip/" + etag + ".gz");
		if(IO.file.exists(gizcachefile)){
			if(F.server("HTTP_IF_NONE_MATCH") == "mae-" + etag){
				Response.Status = "304 Not Modified";
				return;
			}
			Response.AddHeader("Vary","Accept-Encoding");
			Response.AddHeader("Content-Encoding","gzip");
			Response.AddHeader("Etag", "mae-" + etag);
			F.echo(IO.file.readAllBytes(gizcachefile),F.TEXT.BIN);
			return;
		}
		var fs = files.split(";"),filecontent="";
		if(type == "woff" || type=="woff2"){
			var f = F.mappath(files +"." + type);
			if(IO.file.exists(f)) filecontent = IO.file.readAllBuffer(f);
		}else{
			for(var i=0;i<fs.length;i++){
				var f = F.mappath(fs[i]+"." + type);
				if(IO.file.exists(f)) filecontent += IO.file.readAllText(f);
			}
		}
		
		if(filecontent.length>0){
			Response.AddHeader("Vary","Accept-Encoding");
			Response.AddHeader("Content-Encoding","gzip");
			Response.AddHeader("Etag", "mae-" + etag);
			var gzipcontent = Gzip(filecontent);
			IO.file.writeAllBytes(gizcachefile,gzipcontent);
			F.echo(gzipcontent,F.TEXT.BIN);
		}
	}else{
		var fs = files.split(";"),filecontent="";
		for(var i=0;i<fs.length;i++){
			var f = F.mappath(fs[i]+"." + type);
			if(IO.file.exists(f)){
				F.echo(IO.file.readAllBytes(f), F.TEXT.BIN);
			}
		}
	}
};
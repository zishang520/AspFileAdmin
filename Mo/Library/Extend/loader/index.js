/*
loader
*/

function GzipBuffer(content){
	var gzip = require('gzip/deflate');
	return Base64.toBinary(Base64.e(gzip.deflate(content,{gzip:true})));
}

module.exports = function(files, option){
	if(!files) return;
	var type = 'css', isgzip = true, dot_pos = files.lastIndexOf('.');
	if(!/^([\w\/\.\-\_\;]+)$/igm.test(files) || dot_pos<=0 || dot_pos==files.length-1) return;
	type = files.substr(dot_pos+1).toLowerCase();
	if(!/^(css|js|svg|ttf|woff|woff2|eot)$/.test(type)) return;
	files = files.substr(0, dot_pos);
	if(F.server('HTTP_ACCEPT_ENCODING').indexOf('gzip')<0) isgzip=false;
	if(type=='woff' || type=='woff2'){
		Response.ContentType='application/x-font-woff';
	}else if(type == 'css' || type == 'js'){
		Response.ContentType='text/' + type.replace('js','javascript');
	}else if(type == 'svg'){
		Response.ContentType='image/svg-xml';
	}else if(type == 'ttf'){
		Response.ContentType='application/x-font-ttf';
	}else{
		Response.ContentType='application/octet-stream';
	}
	option = option || {};
	if(option.version){
		option.version = '_' + option.version.replace(/[^\d\.]/g, '');
	}
	option.base = option.base || '';
	if(option.base && !/^([\w\-\_\/]+)$/.test(option.base)) return;
	if(isgzip){
		var etag = Crc32(option.base + files + '.' + type + (option.version || '')), gizcachefile = F.mappath((option.cacahe_dir || Mo.Config.Global.MO_APP + 'Cache/Gzip') + '/' + etag + (option.version || '') + '.gz');
		if(IO.file.exists(gizcachefile)){
			if(F.server('HTTP_IF_NONE_MATCH') == 'mae-' + etag){
				Response.Status = '304 Not Modified';
				return;
			}
			Response.AddHeader('Vary','Accept-Encoding');
			Response.AddHeader('Content-Encoding','gzip');
			Response.AddHeader('Etag', 'mae-' + etag);
			F.echo(IO.file.readAllBytes(gizcachefile),F.TEXT.BIN);
			return;
		}
		var fs = files.split(';'),filecontent;
		if(type != 'css' && type != 'js'){
			var f = F.mappath(option.base + files + '.' + type);
			if(IO.file.exists(f)) filecontent = IO.file.readAllBuffer(f);
		}else{
			filecontent = [];
			for(var i=0;i<fs.length;i++){
				var f = F.mappath(option.base + fs[i] + '.' + type);
				if(IO.file.exists(f)) Array.prototype.push.apply(filecontent,Utf8.getBytes(IO.file.readAllText(f)));
			}
		}
		
		if(filecontent.length>0){
			Response.AddHeader('Vary','Accept-Encoding');
			Response.AddHeader('Content-Encoding','gzip');
			Response.AddHeader('Etag', 'mae-' + etag);
			var gzipcontent = GzipBuffer(filecontent);
			IO.file.writeAllBytes(gizcachefile,gzipcontent);
			F.echo(gzipcontent,F.TEXT.BIN);
		}
	}else{
		var fs = files.split(';');
		for(var i=0;i<fs.length;i++){
			var f = F.mappath(option.base + fs[i] + '.' + type);
			if(IO.file.exists(f)) F.echo(IO.file.readAllText(f));
		}
	}
};
'use strict';

var base64 = require("base64");
var JSZip = require("../jszip");
exports.JSZip = JSZip;
exports.JSZip.prototype.addFolder = function(name,folder){
	zipfolder(this.folder(name),folder);
};

function zipfolder(zip,path){
	IO.directory.directories(path,function(f){
		zipfolder(zip.folder(f.name),f.path);
	});
	IO.directory.files(path,function(f){
		zip.file(f.name,base64.fromBinary(IO.file.readAllBytes(f.path)),{base64:true});
	});
}

exports.helper = zipfolder;

/**
 * create zip file from a directory
 * @param {path} source directory path;
 * @param {target} the dest filename;
 * @param {option} options;
 * @return {Boolean} true if succeed, false otherwise
 */
exports.zipFolder = function(path, target, option){
	var zip = new JSZip();
	try{
		zipfolder(zip,path)
		IO.file.writeAllBytes(target,base64.toBinary(zip.generate(option)));
		return true;
	}catch(ex){
		return false;
	}
}

/**
 * create zip file from a file
 * @param {file} source filename;
 * @param {target} the dest filename;
 * @param {option} options;
 * @return {Boolean} true if succeed, false otherwise
 */
exports.zipFile = function(file, target, option){
	option = F.extend({filename:null},option);
	var filename = option.filename || file.substr(file.lastIndexOf("\\")+1);
	var zip = new JSZip();
	try{
		zip.file(filename,base64.fromBinary(IO.file.readAllBytes(file)),{base64:true});
		IO.file.writeAllBytes(target,base64.toBinary(zip.generate(option)));
		return true;
	}catch(ex){
		ExceptionManager.put(ex, "zip.zipFile(file, target, option)");
		return false;
	}
}

/**
 * release zip file to a directory
 * @param {srcfile} source zip-filename;
 * @param {dest} the dest directory path;
 * @param {option} options;
 * @return {Boolean} true if succeed
 */
exports.unZip = function(srcfile,dest,option){
	option = F.extend({base64:true},option);
	var zip = new JSZip(base64.fromBinary(IO.file.readAllBytes(srcfile)) , option);
	var files = zip.files;
	for(var i in files){
		if(!files.hasOwnProperty(i)) continue;
		var file = files[i];
		if(file.dir){
			IO.directory.create(IO.build(dest,file.name));
		}else{
			var destfile = IO.build(dest,file.name),parentDir=IO.parent(destfile);
			if(!IO.directory.exists(parentDir))IO.directory.create(parentDir);
			IO.file.writeAllBytes(destfile,base64.toBinary(base64.e(file._data.getContent())));
		}
	}
	return true;
};
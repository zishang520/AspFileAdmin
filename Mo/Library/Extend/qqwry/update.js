/*
QQWryUpdater js
*/
function QQWryUpdater(){
	var keyfile = __dirname + "\\update\\copywrite.rar", file = __dirname + "\\update\\qqwry.rar", target = __dirname + "\\QQWry.dat";
	HttpRequest("http://update.cz88.net/ip/copywrite.rar").save(keyfile);
	if(!IO.file.exists(keyfile)){
		MEM.putWarning(0x235, "QQWryUpdater", "failed to download copywrite file.");
		return 0;
	}

	/*get key from remote*/
	var fp = IO.file.open(keyfile, {forText:false,forRead:true}), key, buffer, date;
	IO.file.seek(fp, 20);
	key = IO.binary2buffer(IO.file.read(fp, 4));
	IO.file.seek(fp, 24);
	date = GBK.getString(IO.binary2buffer(IO.file.read(fp, 128))).replace(/\0/g,"");
	IO.file.close(fp);
	key = (key[0]) + (key[1]<<8) + (key[2]<<16) + (key[3]<<24);

	//check version
	if(IO.file.exists(target)){
		if(date.indexOf(" ")>0){
			date = date.substr(date.indexOf(" ") + 1);
			var date2 = require("qqwry")("255.255.255.255").address;
			if(date2.indexOf(date)>=0){
				IO.file.del(keyfile);
				return 2;
			}
		}
	}
	HttpRequest("http://update.cz88.net/ip/qqwry.rar").save(file);
	if(!IO.file.exists(file)){
		MEM.putWarning(0x235, "QQWryUpdater", "failed to download update file.");
		return 0;
	}

	/*read compressed data*/
	fp = IO.file.open(file, {forText:true,forRead:true, encoding : "437"});
	buffer = IO.file.readBuffer(fp);
	IO.file.close(fp);
	
	/*decrypt 0x200 byte*/
	for (var i = 0; i<0x200; i++)
    {
        key *= 0x805;
        key++;
        key &= 0xFF;
        buffer[i] = buffer[i] ^ key;
    }

	/*decompress and save*/
	IO.file.writeAllBuffer(target, require("gzip/inflate.js").inflate(buffer));
	IO.file.del(keyfile);
	IO.file.del(file);
	return 1;
}
module.exports = QQWryUpdater;
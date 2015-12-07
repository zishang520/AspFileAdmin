/*
QQWry js
*/

var stream = Server.CreateObject("ADODB.stream"), 
	opened = false, 
	stream_get_long, stream_get_byte;
	
VBS.execute("function stream_get_long(size) : dim i, num : num = 0 : for i=0 to size-1 : num = num + ascb(qqwry_stream.Read(1)) * (256 ^ i) :next : stream_get_long = num : end function\nfunction stream_get_byte() : stream_get_byte = ascb(qqwry_stream.Read(1)) : end function");
VBS.ns("qqwry_stream", stream);

stream_get_long = VBS.eval("GetRef(\"stream_get_long\")");
stream_get_byte = VBS.eval("GetRef(\"stream_get_byte\")");

Mo.on("dispose", function(){
    try{
	    stream.Close();
    }catch(ex){}
    stream = null;
});

function QQWry(ip, raw){
	if(!opened){
		if(!IO.file.exists(QQWry.File)) return {code: 500, msg : "数据库不存在"};
		stream.Type = 1;
		stream.Mode = 3
		stream.Open();
        stream.LoadFromFile(QQWry.File);
        opened = true;
	}
	if(isNaN(ip)) ip = ip2long(ip) || 4294967295;
    stream.Position=0;
    var firstip = stream_get_long(4);
    var lastip = stream_get_long(4);
    var total = (lastip-firstip) / 7;
    var l = 0, u = total, i, beginip, endip;
    
	while(l <= u){
		i = Math.floor((l + u) /2);
		stream.Position = firstip + i * 7;
		beginip = stream_get_long(4);
		if(ip<beginip){
			u = i-1;
		}else{
			stream.Position = stream_get_long(3);
			endip = stream_get_long(4);
			if(ip>endip){
				l = i+1;
			}else{
				lastip = firstip + i * 7;
				break;
			}
		}
	}
	stream.Position = lastip;
	stream.Read(4);
	var offset = stream_get_long(3);
	stream.Position = offset;
    stream.Read(4);
    var flag = stream_get_byte();
	var ncountry, narea;
	if(flag == 1){
		offset = stream_get_long(3);
		stream.Position = offset;
		var nflag = stream_get_byte();
		if(nflag == 2){
			stream.Position = stream_get_long(3);
			ncountry = get_string();
			stream.Position = offset + 4;
			narea = get_area();
		}else{
			stream.Position = stream.Position-1;
			ncountry = get_string();
			narea = get_area();
		}
	}else if(flag == 2){
		stream.Position = stream_get_long(3);
		ncountry = get_string();
		stream.Position = offset + 8;
		narea = get_area();
	}else{
		stream.Position = offset+4;
		ncountry = get_string();
		narea = get_area();
	}
	try{
		ncountry = bin2gbk(ncountry);
		narea = bin2gbk(narea);
		if(raw===true){
			var	state="",city="",area="",
				result = /^(.+?)(省|市)((.+?)(市|县|区)((.+?)(省|市|区|县))?)?$/igm.exec(ncountry.replace(/^(内蒙古|宁夏|广西|西藏|新疆)/,"$1省"));
			if(result){
				state = result[1];
				city = result[4];
				area = result[7]+result[8];
			}
			if(city=="")city = state;
			return {code : 200, location : ncountry, address : narea, state : state, city : city, area : area, ip : long2ip(ip), start : long2ip(beginip), end : long2ip(endip)  };
		}else{
			return {code : 200, location : ncountry, address : narea, ip : long2ip(ip), start : long2ip(beginip), end : long2ip(endip) };
		}
	}catch(ex){
		 return {code: 500, msg : "未知"};
	}
}
QQWry.File = __dirname + "\\QQWry.dat";

function long2ip(lng){
	var ip = [];
	while(lng>0){
		ip.push(lng & 0xff);
		lng = lng >>> 8;
	}
	ip.reverse();
	return ip.join(".");
}

function ip2long(ip){
	var ips = ip.split("."), ipp, lng=0;
	if(ips.length!=4) return 0;
	for(var i=0;i<4;i++){
		ipp = ips[i];
		if(isNaN(ipp)) return 0;
		if(ipp<0 || ipp>255) return 0;
		lng += ipp * Math.pow(256, 3-i);
	}
	return lng;
}

function get_string(){
	var chr, ps = stream.Position, size = 0
	chr = stream_get_byte();
	while(chr>0){
		size = size +1;
		chr = stream_get_byte();
	}
	stream.Position = ps
	var result = stream.Read(size);
	stream.Position = stream.Position + 1
	return result;
}
	
function get_area(){
	var fla = stream_get_byte();
	if(fla == 0){
		return "";
	}
	if(fla == 1 || fla == 2){
		stream.Position = stream_get_long(3);
		return get_string();
	}
	stream.Position = stream.Position-1
	return get_string();
}
function bin2gbk(data){
	var Stream=Server.CreateObject("ADodb.Stream");
	Stream.Mode = 3;
	Stream.Type = 1;
	Stream.Open();
	Stream.Write(data);
	Stream.Position = 0;
	Stream.Type = 2;
	Stream.CharSet = "gbk";
	var result = Stream.ReadText();
	Stream.Close();
	Stream = null;
	return result;
}
module.exports = QQWry;
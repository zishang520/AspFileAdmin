/*
** File: oauth.js
** Usage: create oauth(2.0) request. you know it !
** About: 
**		support@mae.im
*/
var httprequest = require("net/http/request");

function $oauth(client_id, client_secret){
	this.table=[];
	this.client_id = client_id||"";
	this.redirect_uri = "";
	this.authorization_url = "";
	this.access_token_url = "";
	this.refresh_token_url = "";
	this.client_secret = client_secret||"";
	this.debug={};
}
$oauth.fn = $oauth.prototype;
$oauth.fn.toString=function(){
	return "OAUTH 2.0 BY Anlige";	
};
$oauth.fn.getAuthorizationUrl = function(scope, state){
	var url = this.authorization_url + "?client_id=" + F.encode(this.client_id) + "&response_type=code";
	if(scope) url += "&scope=" + F.encode(scope);
	if(state) url += "&state=" + F.encode(state);
	if(this.redirect_uri!="") url += "&redirect_uri=" + F.encode(this.redirect_uri);
	var data = this.getURIString("utf-8")
	if(data!="") url += "&" + data;
	return url;
}
$oauth.fn.gotoAuthorization = function(scope, state){
	return F.redirect(this.getAuthorizationUrl(scope, state));
}
$oauth.fn.catchAuthorization = function(fn){
	if(typeof fn != "function") return;
	var code = F.get("code"), state = F.get("state");
	if(code){
		fn(true,code,state);
	}else{
		fn(false,F.get("error"),F.get("error_description"),F.get("error_uri"));
	}
};
$oauth.fn.getAccessToken = function(code , method, format){
	if(!format){format = "json";}
	if(!method){method = "GET";}
	var data = "grant_type=authorization_code&code=" + F.encode(code)
	if(this.redirect_uri!="") data += "&redirect_uri=" + F.encode(this.redirect_uri);
	if(this.client_id!="") data += "&client_id=" + F.encode(this.client_id);
	//if(this.client_secret!="") data += "&client_secret=" + F.encode(this.client_secret);
	var data1 = this.getURIString("utf-8")
	if(data1!="") data += "&" + data1;
	return this.senddata(this.access_token_url,method,data,format);
};

$oauth.fn.refreshToken = function(refresh_token , method, format){
	if(!format){format = "json";}
	if(!method){method = "GET";}
	var data = "grant_type=refresh_token&client_id=" + F.encode(this.client_id) + "&refresh_token=" + F.encode(refresh_token) + "&client_secret=" + F.encode(this.client_secret)
	var data1 = this.getURIString("utf-8")
	if(data1!="") data += "&" + data1;
	return this.senddata(this.refresh_token_url,method,data,format);
};
$oauth.fn.fetchFromAPI = function(api, method, format){
	format = format || "text";
	method = method || "GET";
	return this.senddata(api,method,this.getURIString("utf-8"),format);
};

$oauth.fn.senddata = function(url,method,data,format){
	var myhttp = new httprequest(url,method,data);
	myhttp.autoClearBuffer=false;
	myhttp.send();
	var result;
	if(format=="json"){
		result =myhttp.getjson("utf-8");
	}else if(format=="xml"){
		result =myhttp.getxml("utf-8");
	}else{
		result =myhttp.gettext("utf-8");	
	}
	this.debug["url"]=myhttp.url;
	this.debug["data"]=data;
	myhttp = null;
	return result;	
};

$oauth.fn.getURIString = function(charset,split1,split2){
	charset = (charset || "utf8").toLowerCase();
	split1 = split1 || "=";
	split2 = split2 || "&";
	var str = "";
	for(var i in this.table){
		if(!this.table.hasOwnProperty(i)) continue;
		if(this.table[i]===null){continue;}
		var val = this.table[i];
		if(charset=="gbk"){
			str += i + split1 + escape(val) + split2;
		}else if(charset=="no"){
			str += i + split1 + val + split2;
		}else{
			str += i + split1 + F.encode(val) + split2;
		}
	}
	if(str!=""){
		str = str.substr(0,str.length-split2.length);	
	}
	return str;	
};

$oauth.fn.set = function(key,value){
	this.table[key] = value || "";
};
$oauth.fn.get = function(key){
	return this.table[key] || "";
};

$oauth.fn.remove = function(key){
	if(!key){this.table={};return;}
	if(!this.table.hasOwnProperty(key)) return;
	delete this.table[key];
};
$oauth.fn.rndstr=function(len){
	var slen = "0123456789qwertyuioplkjhgfdsazxcvbnmQWERTYUIOPLKJHGFDSAZXCVBNM";
	var retstr="";
	for(var i=0;i<len;i++){
		retstr+=slen.substr(parseInt(Math.random()*slen.length),1);
	}
	return retstr;
};
module.exports = $oauth;
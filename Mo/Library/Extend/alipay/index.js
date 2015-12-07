/*alipay*/


var $alipay = function(partner, key, wap){
	var _charset = "utf-8", _partner = partner, _key = key, _wap = wap===true;
	var api = "https://mapi.alipay.com/gateway.do";
	var parms = {
		service : "create_direct_pay_by_user",
		partner : _partner,
		_input_charset : _charset,
		notify_url : "",
		return_url : "",
		error_notify_url : "",

		/*business parms*/
		out_trade_no : "",
		subject : "",
		body : "",
		payment_type : "1",
		total_fee : "",
		seller_id :_partner,
		show_url : "",
		it_b_pay : "" //1m～15d
	};
	if(wap){
		F.extend(parms, {
			service : "alipay.wap.create.direct.pay.by.user",
			extern_token : "",
			otherfee : "",
			airticket : ""
		});
	}else{
		F.extend(parms,{
			paymethod : "directPay", //creditPay
			price : "",
			quantity : "",
			seller_email : "",
			seller_account_name : "",
			buyer_id : "",
			buyer_email : "",
			buyer_account_name : "",
			enable_paymethod : "",//directPay^bankPay^cartoon^cash
			need_ctu_check : "", //Y/N
			royalty_type : "", //10
			royalty_parameters : "",
			anti_phishing_key : "",
			exter_invoke_ip : "",
			extra_common_param : "",
			extend_param : "",
			default_login : "", //Y/N
			product_type : "", //CHANNEL_FAST_PAY 
			token : "",
			item_orders_info : "",
			sign_id_ext : "",
			sign_name_ext : "",
			qr_pay_mode : ""
		});
	}
	
	function dosign(){
		var item = "", args=[];
		for(var i in parms){
			if(!parms.hasOwnProperty(i)) continue;
			item = parms[i];
			if(item) args.push(i);
		}
		F.sortable.data__ = args;
		F.sortable.sort();
		var data = F.sortable.data__, len = data.length, str = "", posts="";
		for(var i=0;i<len;i++){
			str += data[i] + "=" + parms[data[i]] + "&";
			posts += data[i] + "=" + F.encode(parms[data[i]]) + "&";
		}
		str = str.substr(0,str.length-1) + _key;
		posts += "sign_type=MD5&sign=" + MD5(Utf8.getByteArray(str));
		return posts;
	}
	function justsign(_parms){
		var item = "", args=[];
		for(var i in _parms){
			if(!_parms.hasOwnProperty(i)) continue;
			item = _parms[i];
			if(item) args.push(i);
		}
		F.sortable.data__ = args;
		F.sortable.sort();
		var data = F.sortable.data__, len = data.length, str = "", posts="";
		for(var i=0;i<len;i++){
			str += data[i] + "=" + _parms[data[i]] + "&";
		}
		str = str.substr(0,str.length-1) + _key;
		return MD5(Utf8.getByteArray(str));
	}
	function verify_id(id){
		return HttpRequest("https://mapi.alipay.com/gateway.do?service=notify_verify&partner=" + _partner + "&notify_id=" + F.encode(id)).gettext()=="true";
	}
	function verify(col){
		var _parms = [];

		var getstr = col() + "";
		var obj = F.object.fromURIString(getstr), sign = obj["sign"], sign_type = obj['sign_type'];
		delete obj["a"];
		delete obj["sign"];
		delete obj["sign_type"];
		parms = obj;
		var result = justsign(obj);
		if(result != sign) return false;
		
		var notify_id = col("notify_id") + "";
		if(notify_id!=""){
			if(!verify_id(notify_id)) return false;
		}
		return true;
	}
	var instance = function(key, value){
		if(value===undefined) return parms[key] || "";
		parms[key] = value;
	};
	instance.get_redirect_url = function(notify_url, return_url, error_notify_url){
		if(notify_url) parms["notify_url"] = notify_url;
		if(return_url) parms["return_url"] = return_url;
		if(error_notify_url) parms["error_notify_url"] = error_notify_url;
		return api + "?" + dosign();
	};
	instance.verify_return = function(){
		return verify(Request.QueryString);
	};
	instance.verify_notify = function(){
		return verify(Request.Form);
	};
	return instance;
};
module.exports = $alipay;
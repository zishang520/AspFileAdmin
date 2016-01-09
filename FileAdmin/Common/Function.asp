<script language="jscript" runat="server">
/**
 * [FileName 获取当前名称]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:12:08+0800
 * @param    {[type]}                 path [description]
 */
 FileName = function(path) {
    var filename = path.substr(path.lastIndexOf("\\") + 1);
    return filename;
};
/**
 * [Path 获取父级路径]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:12:21+0800
 * @param    {[type]}                 paths [description]
 */
 Path = function(paths) {
    var path = paths.substr(0, paths.lastIndexOf("\\"));
    return path;
};
/**
 * [CharSetTest 编码]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:12:25+0800
 * @param    {[type]}                 type [description]
 */
 CharSetTest = function(type) {
    switch (type) {
        case 1:
        charset = 'utf-8';
        break;
        case 2:
        charset = 'gb2312';
        break;
        case 3:
        charset = 'gbk';
        break;
        case 4:
        charset = 'big5';
        break;
        default:
        charset = 'utf-8';
        break;
    }
    return charset;
};
/**
 * [SizeConvert 文件大小转换]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:12:30+0800
 * @param    {[type]}                 bytes [description]
 */
 SizeConvert = function(bytes) {
    var size, bytesize, bytes = parseInt(bytes);
    if (bytes >= 1073741824) {
        bytesize = parseInt((bytes / 1073741824) * 1000) / 1000;
        size = bytesize + " GB";
    } else if (bytes >= 1048576) {
        bytesize = parseInt((bytes / 1048576) * 1000) / 1000;
        size = bytesize + " MB";
    } else if (bytes >= 1024) {
        bytesize = parseInt((bytes / 1024) * 1000) / 1000;
        size = bytesize + " KB";
    } else {
        size = bytes + " Byte"
    }
    return size;
};
/**
 * [SizePercent 计算磁盘使用百分比]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:12:39+0800
 * @param    {[type]}                 sizea [description]
 * @param    {[type]}                 sizeb [description]
 */
 SizePercent = function(sizea, sizeb) {
    var percent = parseInt(sizea) / parseInt(sizeb);
    var percent = 100 - parseInt(percent * 100);
    return parseInt(percent);
};
/**
 * [VolumenameAuto 磁盘类型]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:12:43+0800
 * @param    {[type]}                 number [description]
 */
 VolumenameAuto = function(number) {
    var typename;
    var type = parseInt(number) + 1;
    switch (type) {
        case 1:
        typename = '设备无法识别';
        break;
        case 2:
        typename = '可移动磁盘';
        break;
        case 3:
        typename = '本地磁盘';
        break;
        case 4:
        typename = '网络磁盘';
        break;
        case 5:
        typename = 'CD/ROM光盘';
        break;
        case 6:
        typename = '随机存储器';
        break;
        default:
        typename = '未知磁盘';
        break;
    }
    return typename;
};
/**
 * [ip2long IP转换都整型]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:12:49+0800
 * @param    {[type]}                 ip [description]
 * @return   {[type]}                    [description]
 */
 ip2long = function(ip) {
    var num = 0;
    ip = ip.split(".");
    num = Number(ip[0]) * 256 * 256 * 256 + Number(ip[1]) * 256 * 256 + Number(ip[2]) * 256 + Number(ip[3]);
    num = num >>> 0;
    return num;
};
/**
 * [long2ip 整型转ip]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:12:59+0800
 * @param    {[type]}                 num [description]
 * @return   {[type]}                     [description]
 */
 long2ip = function(num) {
    var str;
    var tt = new Array();
    tt[0] = (num >>> 24) >>> 0;
    tt[1] = ((num << 8) >>> 24) >>> 0;
    tt[2] = (num << 16) >>> 24;
    tt[3] = (num << 24) >>> 24;
    str = String(tt[0]) + "." + String(tt[1]) + "." + String(tt[2]) + "." + String(tt[3]);
    return str;
};
/**
 * [Add 加法运算]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:13:03+0800
 * @param    {[type]}                 arg1 [description]
 * @param    {[type]}                 arg2 [description]
 */
 Add = function(arg1, arg2) {
    return parseInt(arg1) + parseInt(arg2);
};
/**
 * [Sub 减法]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:13:06+0800
 * @param    {[type]}                 arg1 [description]
 * @param    {[type]}                 arg2 [description]
 */
 Sub = function(arg1, arg2) {
    return parseInt(arg1) - parseInt(arg2);
};
/**
 * [FloatAdd 浮点加法]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:13:21+0800
 * @param    {[type]}                 arg1 [description]
 * @param    {[type]}                 arg2 [description]
 */
 FloatAdd = function(arg1, arg2) {
    var r1, r2, m;
    try {
        r1 = arg1.toString().split(".")[1].length
    } catch (e) {
        r1 = 0
    }
    try {
        r2 = arg2.toString().split(".")[1].length
    } catch (e) {
        r2 = 0
    }
    m = Math.pow(10, Math.max(r1, r2))
    return (arg1 * m + arg2 * m) / m
};
/**
 * [FloatSub 浮点减法]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:14:43+0800
 * @param    {[type]}                 arg1 [description]
 * @param    {[type]}                 arg2 [description]
 */
 FloatSub = function(arg1, arg2) {
    var r1, r2, m, n;
    try {
        r1 = arg1.toString().split(".")[1].length
    } catch (e) {
        r1 = 0
    }
    try {
        r2 = arg2.toString().split(".")[1].length
    } catch (e) {
        r2 = 0
    }
    m = Math.pow(10, Math.max(r1, r2));
    //动态控制精度长度
    n = (r1 >= r2) ? r1 : r2;
    return ((arg1 * m - arg2 * m) / m).toFixed(n);
};

/**
 * [FloatMul 浮点乘法]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:14:49+0800
 * @param    {[type]}                 arg1 [description]
 * @param    {[type]}                 arg2 [description]
 */
 FloatMul = function(arg1, arg2) {
    var m = 0,
    s1 = arg1.toString(),
    s2 = arg2.toString();
    try {
        m += s1.split(".")[1].length
    } catch (e) {}
    try {
        m += s2.split(".")[1].length
    } catch (e) {}
    return Number(s1.replace(".", "")) * Number(s2.replace(".", "")) / Math.pow(10, m)
};

/**
 * [FloatDiv 浮点除法]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:14:54+0800
 * @param    {[type]}                 arg1 [description]
 * @param    {[type]}                 arg2 [description]
 */
 FloatDiv = function(arg1, arg2) {
    var t1 = 0,
    t2 = 0,
    r1, r2;
    try {
        t1 = arg1.toString().split(".")[1].length
    } catch (e) {}
    try {
        t2 = arg2.toString().split(".")[1].length
    } catch (e) {}
    with(Math) {
        r1 = Number(arg1.toString().replace(".", ""))
        r2 = Number(arg2.toString().replace(".", ""))
        return (r1 / r2) * pow(10, t2 - t1);
    }
};
/**
 * [writeObj 输出obj]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:14:58+0800
 * @param    {[type]}                 obj [description]
 * @return   {[type]}                     [description]
 */
 writeObj = function(obj) {
    var description = "";
    for (var i in obj) {
        var property = obj[i];
        description += i + " => " + property + "\r\n";
    }
    console.log(description);
};

/**
 * [empty description]
 * @Author   ZiShang520
 * @DateTime 2016-01-10T01:28:26+0800
 * @param    {[type]}                 obj [description]
 * @return   {[type]}                     [description]
 */
empty=function (obj){
    for(var name in obj){
        return false;
    }
    return true;
}
/**
 * [is_post 判断是否post]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:11:58+0800
 * @return   {Boolean}                [description]
 */
 is_post = function() {
    if (!is_empty(F.server('REQUEST_METHOD'))) {
        if (F.server('REQUEST_METHOD') == 'POST') {
            return true;
        } else {
            return false;
        }
    } else {
        return false;
    }
};

/**
 * ajax
 * @Author   ZiShang520
 * @DateTime 2016-01-08T11:22:32+0800
 * @return   {Boolean}                [description]
 */
 is_ajax = function() {
    if (!is_empty(F.server('HTTP_X_REQUESTED_WITH'))) {
        if (F.server('HTTP_X_REQUESTED_WITH') == 'XMLHttpRequest') {
            return true;
        } else {
            return false;
        }
    } else {
        return false;
    }
};

/**
 * 是否已经安装
 * @Author   ZiShang520
 * @DateTime 2016-01-09T21:45:30+0800
 * @return   {Boolean}                [description]
 */
 is_install = function() {
    var info = MCM("User");
    if (is_empty(info('USER')) || is_empty(info('PASS')) || is_empty(info('KEY')) || is_empty(info('IV'))) {
        return false;
    } else {
        return true;
    }
};
/**
 * 获取安装信息
 * @Author   ZiShang520
 * @DateTime 2016-01-09T21:58:24+0800
 * @param    {[type]}                 key [description]
 * @return   {[type]}                     [description]
 */
 get_install = function(key) {
    if (is_install()) {
        var info = MCM("User");
        if (!is_empty(key)) {
            return info(key);
        } else {
            return info.config;
        }
    }else{
        return undefined;
    }
};
/**
 * 字符串替换
 * @Author   ZiShang520
 * @DateTime 2016-01-08T10:14:50+0800
 * @param    {[type]}                 str [description]
 * @return   {[type]}                     [description]
 */
 str_replace = function(str) {
    str = str || '';
    str = str.replace(/\\/ig, '\\\\');
    // str=str.replace(/'/ig , "\\'");
    str = str.replace(/"/ig, '\\"');
    str = str.replace(/\r/ig, '\\r');
    str = str.replace(/\n/ig, '\\n');
    str = str.replace(/\t/ig, '&nbsp;&nbsp;&nbsp;&nbsp;');
    str = str.replace(/\s/ig, '&nbsp;');
    return str;
};
</script>

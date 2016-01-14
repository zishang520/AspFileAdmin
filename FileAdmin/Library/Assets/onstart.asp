<script language="jscript" runat="server">
    onstart = IClass.create();
    onstart.extend("Index", function() {
    var __LATE = is_install()?get_install('KEY'):'3#14519/14627/35521/39041/15797/17123'; //密钥
    var __IV = is_install()?get_install('IV'):'9#a64256a8b/5b2e99b/3cab659dc/3391bfd'; //偏移
    var CryptoJS = require("cryptojs");//核心算法
    /**
     * 加密核心
     * @Author   ZiShang520
     * @DateTime 2016-01-09T20:41:31+0800
     * @param    {[type]}                 str       [description]
     * @param    {[type]}                 condition [description]
     */
     AES_ED = function(str, condition) {
        CryptoJS.require.Padding().Mode();
        CryptoJS.require['AES']().Format.Hex();
        var key = CryptoJS.enc.Utf8.parse(__LATE);
        var iv = CryptoJS.enc.Utf8.parse(__IV);
        var cfg = {
            iv: iv,
            mode: CryptoJS.mode['ECB'], //加密模式
            padding: CryptoJS.pad['AnsiX923'], //补丁算法
            format: CryptoJS.format.Hex
        };
        if (condition == 1) { //加密
            var srcs = CryptoJS.enc.Utf8.parse(str);
            return CryptoJS['AES'].encrypt(srcs, key, cfg).toString();
        } else if (condition == 2) { //解密
            var srcs = CryptoJS.enc.Hex.parse(str);
            var decryptdata = CryptoJS['AES'].decrypt(CryptoJS.lib.CipherParams.create({
                ciphertext: srcs
            }), key, cfg);
            return decryptdata.toString(CryptoJS.enc.Utf8);
        }
    };

    /**
     * [Auth description]
     * @Author   ZiShang520
     * @DateTime 2016-01-10T00:59:32+0800
     */
     Auth = function (){
        var Hash = require("PasswordHash");
        var result = new Hash(5,20);
        var ctrl = Mo.A("Public");
        var adminsession = F.session.parse("admin");
        var admincookie = cookie("Z_Cookies");
        if (!empty(admincookie)) {
            if (!empty(adminsession)) {
                if (AES_ED(adminsession['__Hash'],1)!==admincookie.__Hash || adminsession['__token']!==admincookie.__token) {
                    cookie("Z_Cookies",'',{expires: '1970-01-01 00:00:00'});
                    F.session.destroy(true);
                    ctrl.Login();
                    F.exit();
                }
            }else{
                var admincookiesinfo=F.json(AES_ED(admincookie.__Hash,2));
                if (!is_empty(admincookiesinfo)) {
                    if (is_empty(admincookiesinfo['username']) || is_empty(admincookiesinfo['password']) || is_empty(admincookiesinfo['datetime']) || admincookiesinfo['username']!==get_install('USER') || result.CheckPassword(admincookiesinfo['password'],get_install('PASS'))) {
                        cookie("Z_Cookies",'',{expires: '1970-01-01 00:00:00'});
                        ctrl.Login();
                        F.exit();
                    }else{
                        var ip = ip2long(F.server("REMOTE_ADDR"));
                        var datetime = admincookiesinfo['datetime'];
                        var string = '{"username":"' + get_install('USER') + '","password":"' + admincookiesinfo['password'] + '","ip":' + ip + ',"datetime":"' + datetime + '"}';
                        var token = MD5(string);
                        var value = AES_ED(string, 1);
                        var overtime = !is_empty(F.post('ispersis')) ? F.untimespan(datetime) : undefined;
                        cookie("Z_Cookies", {
                            __Hash: value,
                            __token: token
                        }, {
                            expires: overtime,
                            secure: false,
                            httponly: true,
                            path: "/"
                        });
                        F.session("admin.__Hash",string);
                        F.session("admin.__token",token);
                    }
                }else{
                    cookie("Z_Cookies",'',{expires: '1970-01-01 00:00:00'});
                    ctrl.Login();
                    F.exit();
                }
            }
        }else{
            ctrl.Login();
            F.exit();
        }
    };

    /**
     * 自动验证令牌
     * @Author   ZiShang520
     * @DateTime 2016-01-09T20:40:56+0800
     * @param    {[type]}                 F.server('HTTP_X_REQUESTED_WITH') [description]
     * @return   {[type]}                                                   [description]
     */
     if (F.server('HTTP_X_REQUESTED_WITH') == 'XMLHttpRequest') {
        if (is_empty(F.server('HTTP_X_CSRF_TOKEN')) || is_empty(F.session('__csrf')) || is_empty(cookie('__csrf')) || F.server('HTTP_X_CSRF_TOKEN') !== F.session('__csrf') || MD5(F.server('HTTP_X_CSRF_TOKEN') + __LATE) !== cookie('__csrf') || MD5(F.session('__csrf') + __LATE) !== cookie('__csrf')) {
            var ctrl = Mo.A("Error");
            ctrl.Index(); //调用Error控制器的Index方法
            F.exit();
        }
    } else {
        if (F.server('REQUEST_METHOD') == 'POST') {
            if (is_empty(F.all('__csrf')) || is_empty(F.session('__csrf')) || is_empty(cookie('__csrf')) || F.all('__csrf') !== F.session('__csrf') || MD5(F.all('__csrf') + __LATE) !== cookie('__csrf') || MD5(F.session('__csrf') + __LATE) !== cookie('__csrf')) {
                var ctrl = Mo.A("Error");
                ctrl.Index(); //调用Error控制器的Index方法
                F.exit();
            }
            // F.session.destroy("__csrf");
        }
    }
    if (!is_empty(F.session('__csrf'))) {
        Mo.assign('__csrf', F.session('__csrf'));
    } else {
        var __csrf = AES_ED(ip2long(F.server("REMOTE_ADDR")) + F.formatdate(new Date(), "HH:mm:ss"), 1);
        cookie('__csrf', MD5(__csrf + __LATE));
        F.session('__csrf', __csrf);
        Mo.assign('__csrf', __csrf);
    }
    /**
     * 错误信息
     * @Author   ZiShang520
     * @DateTime 2016-01-09T20:42:43+0800
     * @param    {[type]}                 !is_empty(F.session('__error')) [description]
     * @return   {[type]}                                                 [description]
     */
     if (!is_empty(F.session('__error'))) {
        var error = F.session('__error');
        Mo.assign('error', error);
        F.session.destroy('__error');
    }
});
</script>
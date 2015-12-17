<script language="jscript" runat="server">
onstart = IClass.create();
onstart.extend("Index", function() {
    var __LATE = '3#14519/14627/35521/39041/15797/17123'; //加密密钥
    var __IV = '9#a64256a8b/5b2e99b/3cab659dc/3391bfd'; //质数
    var CryptoJS = require("cryptojs");
    AES_EN = function(str, condition) {
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
    }
    if (F.server('HTTP_X_REQUESTED_WITH') == 'XMLHttpRequest') {
        if (F.server('HTTP_X_CSRF_TOKEN') !== F.session('__csrf') || F.server('HTTP_X_CSRF_TOKEN') !== cookie('__csrf') || F.session('__csrf') !== cookie('__csrf')) {
            var ctrl = Mo.A("Error");
            ctrl.Index(); //调用Home控制器的Index方法
            F.exit();
        }
    } else {
        if (F.server('REQUEST_METHOD') == 'POST') {
            //如果是文件上传，暂时不检测，还没找到好的方法代替
            if (F.string.startsWith(F.server('CONTENT_TYPE'),"multipart/form-data")) {
                if (F.session('__csrf') !== cookie('__csrf')) {
                    var ctrl = Mo.A("Error");
                    ctrl.Index(); //调用Home控制器的Index方法
                    F.exit();
                }
            } else {
                if (F.post('__csrf') !== F.session('__csrf') || F.post('__csrf') !== cookie('__csrf') || F.session('__csrf') !== cookie('__csrf')) {
                    var ctrl = Mo.A("Error");
                    ctrl.Index(); //调用Home控制器的Index方法
                    F.exit();
                }
            }
        }
    }
    if (!is_empty(F.session('__csrf'))) {
        Mo.assign('__csrf', F.session('__csrf'));
    } else {
        var __csrf = AES_EN(ip2long(F.server("REMOTE_ADDR")) + F.formatdate(new Date(), "HH:mm:ss"), 1);
        cookie('__csrf', __csrf);
        F.session('__csrf', __csrf);
        Mo.assign('__csrf', __csrf);
    }
    if (!is_empty(F.session('__error'))) {
        var error = F.session('__error');
        Mo.assign('error', error);
        F.session.destroy('__error');
    }
});
</script>
<script language="jscript" runat="server">
/**
 * [LoginController description]
 * @type {[type]}
 */
 PublicController = IController.create();

/**
 * 登陆前台
 * @Author   ZiShang520
 * @DateTime 2016-01-09T20:47:46+0800
 * @param    {[type]}                 ){                 if (is_post()) {        dump(F.post());        dump(F.session('__csr'))    }    this.display('Login:Index'); } [description]
 * @return   {[type]}                     [description]
 */
 PublicController.extend('Login', function() {
    if (!is_install()) {
        F.goto(Mo.U('Public/Install'));
        F.exit();
    }
    var info;
    if (is_post()) {
        var Hash = require("PasswordHash");
        var result = new Hash(5,20);
        var psafe = F.post("code");
        var ssafe = F.session("code");
        if (!is_empty(psafe) && !is_empty(ssafe) && psafe.toLocaleLowerCase() === ssafe.toLocaleLowerCase()) {
            var username = F.post('username');
            var password = F.post('password');
            if (!is_empty(username) && !is_empty(password)) {
                if (get_install('USER') === username && result.CheckPassword(password,get_install('PASS'))) {
                    var ip = ip2long(F.server("REMOTE_ADDR"));
                    var datetime = parseInt(F.timespan(new Date())) + 24 * 3600;
                    var string = '{"username":"' + username + '","password":"' + password + '","ip":' + ip + ',"datetime":"' + datetime + '"}';
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
                    info = {
                        info: '登陆成功',
                        status: 1
                    };
                } else {
                    info = {
                        info: '用户名或密码错误',
                        status: 0
                    };
                }
            } else {
                info = {
                    info: '用户名和密码不能为空',
                    status: 0
                };
            }
        } else {
            info = {
                info: '验证码错误',
                status: 0
            };
        }
        F.session.destroy("code");
    }
    var url=(Mo.Action=='Login')?Mo.U('Home/Index'):(!is_empty(F.server('HTTP_REFERER'))?F.server('HTTP_REFERER'):Mo.U());
    this.assign('url', url);
    this.assign('info', info);
    this.display('Login:Index');
});

/**
 * install
 * @Author   ZiShang520
 * @DateTime 2016-01-10T01:33:26+0800
 * @param    {[type]}                 ) {               if (!is_install()) {        var info;        if (is_post()) {            var psafe [description]
 * @return   {[type]}                   [description]
 */
 PublicController.extend('Install', function() {
    if (!is_install()) {
        var Hash = require("PasswordHash");
        var result = new Hash(5,20);
        var info;
        if (is_post()) {
            var psafe = F.post("code");
            var ssafe = F.session("code");
            if (!is_empty(psafe) && !is_empty(ssafe) && psafe.toLocaleLowerCase() === ssafe.toLocaleLowerCase()) {
                var user = F.post('username');
                var pass = F.post('password');
                var rpass = F.post('rpassword');
                if (!is_empty(user) && !is_empty(pass) && !is_empty(rpass)) {
                    if (pass === rpass) {
                        var info = MCM("User");
                        info({
                            USER: user,
                            PASS: result.HashPassword(pass),
                            KEY: result.HashPassword(user + pass + F.formatdate(new Date(), "HH:mm:ss")),
                            IV: result.HashPassword(user + SHA1(pass) + F.formatdate(new Date(), "HH:mm:ss"))
                        });
                        if (info.save()) {
                            info = {
                                info: '安装成功',
                                status: 1
                            };
                            F.session.destroy("__csrf");
                        } else {
                            info = {
                                info: '安装失败',
                                status: 0
                            };
                        }
                    } else {
                        info = {
                            info: '两次输入的密码不相等',
                            status: 0
                        };
                    }
                } else {
                    info = {
                        info: '用户名和密码不能为空',
                        status: 0
                    };
                }
            } else {
                info = {
                    info: '验证码错误',
                    status: 0
                };
            }
            F.session.destroy("code");
        }
        this.assign('info', info);
        this.display('Install:Index');
    } else {
        F.goto(Mo.U('Home/Index'));
    }
});

/**
 * Code
 * @Author   ZiShang520
 * @DateTime 2016-01-09T23:57:31+0800
 * @param    {[type]}                 ){                 ExceptionManager.errorReporting(E_ERROR);    Safecode("code", {padding:8, odd:3, font:'yahei'});} [description]
 * @return   {[type]}                     [description]
 */
 PublicController.extend("Code",function(){
    ExceptionManager.errorReporting(E_ERROR);
    Safecode("code", {padding:8, odd:3, font:'yahei'});
});

/**
 * 加载文件
 * @Author   ZiShang520
 * @DateTime 2015-12-30T15:07:18+0800
 * @param    {[type]}                 ) {               var Loader [description]
 * @return   {[type]}                   [description]
 */
 PublicController.extend("Loader", function() {
    var Loader = require("loader");
    if(Loader){
        if (F.get('load')=='js') {
            Loader('/FileAdminIndex/js/jquery.min;/FileAdminIndex/js/bootstrap.min;/FileAdminIndex/js/select2.full.min.js');
        }
        if (F.get('load')=='css') {
            Loader('/FileAdminIndex/css/select2.min;/FileAdminIndex/css/zi-all.css');
        }
        if (F.get('load')=='codejs') {
            Loader('/FileAdminIndex/js/code.min.js');
        }
        if (F.get('load')=='codecss') {
            Loader('/FileAdminIndex/css/code.min.css');
        }
    }
});

 /**
 * 空方法
 * @Author   ZiShang520
 * @DateTime 2016-01-09T21:07:00+0800
 * @param    {[type]}                 name){                 F.echo("错误：未定义" + name + "方法");} [description]
 * @return   {[type]}                         [description]
 */
 PublicController.extend("empty", function(name){
    F.goto(Mo.U('Home/Index'));
});
</script>
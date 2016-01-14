<script language="jscript" runat="server">
/**
 * [HomeController description]
 * @type {[type]}
 */
 HomeController = IController.create(function(){
    if (!is_install()) {
        F.goto(Mo.U('Public/Install'));
        F.exit();
    }
    Auth();
});
/**
 * [磁盘下列表]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:18:09+0800
 * @param    {[type]}                 ){    var path,p; var   gpath [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("Index", function() {
    var path, p;
    var gpath = F.decode(F.get('Path'));
    if (!is_empty(gpath) && IO.is(gpath) && IO.directory.exists(gpath)) {
        path = gpath;
    } else {
        path = F.mappath("../");
    }
    var upaths = IO.parent(path);
    var upath = (!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths)) ? Mo.U('Home/Index', 'Path=' + F.encode(upaths)) : Mo.U('Home/Drive'); //生成上级路径信息
    var directories = [];
    IO.directory.directories(path, function(directorie) {
        directories.push(directorie);
    });
    var directories = (directories.length != 0) ? directories : null; //文件夹列表
    var files = [];
    IO.directory.files(path, function(file) {
        files.push(file);
    });
    var files = (files.length != 0) ? files : null; //文件列表
    this.assign("files", files);
    this.assign("directories", directories);
    this.assign("upath", upath);
    this.assign("path", path);
    this.display('Home:Index');
});
/**
 * [磁盘目录]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:18:18+0800
 * @param    {Array}                  ){    var drives        [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("Drive", function() {
    var drives = [];
    IO.drive.drives(function(drive) {
        drives.push(drive);
    });
    this.assign("drives", drives);
    this.display('Home:Drive');
});
/**
 * [查看文件]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:18:23+0800
 * @param    {[type]}                 ){    var charset,content;    var filepath [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("Show", function() {
    var charset, content;
    var filepath = F.decode(F.get('Path'));
    var upaths = IO.parent(filepath);
    var upath = (!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths)) ? Mo.U('Home/Index', 'Path=' + F.encode(upaths)) : Mo.U('Home/Drive'); //生成上级路径信息
    if (!is_empty(filepath) && IO.is(filepath) && IO.file.exists(filepath)) {
        var file = IO.file.get(filepath);
        if (file.size < 1024000) {
            var charsetint = F.get.int("CharSet", 1);
            charset = CharSetTest(charsetint);
            content = F.encodeHtml(IO.file.readAllText(filepath, charset));
        } else {
            content = '文件内容超过1Mb，请下载后查看';
        }
    } else {
        content = '读取文件不存在';
    }
    this.assign('filepath', filepath);
    this.assign("content", content);
    this.assign("upath", upath);
    this.display('Home:Show');
});

/**
 * [文件上传]
 * @Author   ZiShang520
 * @DateTime 2015-12-09T23:47:05+0800
 * @param    {[type]}                 ){} [description]
 * @return   {[type]}                       [description]
 */
 HomeController.extend("Upload", function() {
    var upload = require("net/upload"); //引入上传模块
    var content, info;
    var filepath = F.decode(F.get('Path'));
    // var upaths=IO.parent(filepath);
    var upath = (!is_empty(filepath) && IO.is(filepath) && IO.directory.exists(filepath)) ? Mo.U('Home/Index', 'Path=' + F.encode(filepath)) : Mo.U('Home/Drive'); //生成路径信息
    if (!is_empty(filepath) && IO.is(filepath) && IO.directory.exists(filepath)) {
        if (is_post()) {
            upload({
                AllowFileTypes: "*",
                /*only these extensions can be uploaded.*/
                AllowMaxSize: "4Mb",
                /*max upload-data size*/
                Charset: "utf-8",
                /*client text charset*/
                SavePath: filepath,
                /*dir that files will be saved in it.*/
                RaiseServerError: false /* when it is false, don not push exception to Global ExceptionManager, just save in F.exports.upload.exception.*/ ,
                OnError: function(e, cfg) { /*event, on some errors are raised. */
                    info = {
                        'info': e,
                        'status': 0
                    };
                },
                OnSucceed: function(cfg) {
                    var filesnum = this.files.length;
                    this.save("upfile", {
                        Type: UploadSaveType.NONE,
                        OnError: function(e) {
                            info = {
                                'info': e,
                                'status': 0
                            };
                        },
                        OnSucceed: function(count, files) {
                            info = {
                                'info': '文件:' + F.post('upfile') + '共' + filesnum + '个文件上传完成',
                                'status': 1
                            };
                        }
                    });
                }
            });
}
} else {
    content = '目标文件夹不存在';
}
this.assign("info", info);
this.assign('filepath', filepath);
this.assign("content", content);
this.assign("upath", upath);
this.display('Home:Upload');
});

/**
 * [下载]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:18:31+0800
 * @param    {[type]}                 ){    var filepath      [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("Dowload", function() {
    var filepath = F.decode(F.get('Path'));
    var upaths = IO.parent(filepath);
    var upath = (!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths)) ? Mo.U('Home/Index', 'Path=' + F.encode(upaths)) : Mo.U('Home/Drive'); //生成上级路径信息
    if (!is_empty(filepath) && IO.is(filepath) && IO.file.exists(filepath)) {
        var range = F.server('HTTP_RANGE'),
        inits, stops;
        var file = IO.file.get(filepath);
        if (file.size>0) {
            if (!is_empty(range)) {
                var byt = F.string.matches(range, /bytes\=(\d+)?-(\d+)?/ig);
                if (byt.length > 0) {
                    inits = !is_empty(byt[0][1]) ? parseInt(byt[0][1]) : 0;
                    if (inits == 0) {
                        stops = file.size - 1;
                    } else if (inits > 0 && is_empty(byt[0][2])) {
                        stops = file.size - 1;
                    } else {
                        stops = (!is_empty(byt[0][2]) && inits < (parseInt(byt[0][2]))) ? parseInt(byt[0][2]) : file.size - 1;
                    }
                } else {
                    inits = 0;
                    stops = file.size - 1;
                }
            } else {
                inits = 0;
                stops = file.size - 1;
            }
            if (stops <= file.size) {
                Response.Buffer = true; //开启缓存完毕输出
                Response.Clear(); //清除缓存
                var stream = new ActiveXObject("ADODB.Stream"); //解决下载限制
                stream.Mode = 3; //读写模式
                stream.Type = 1; //二进制
                stream.Open();
                stream.LoadFromFile(filepath);
                stream.Position = inits; //流指针
                Response.Status = "206 Partial Content";
                Response.ContentType = "application/octet-stream";
                Response.AddHeader('Accept-Ranges', 'bytes');
                Response.AddHeader("Content-Disposition", "attachment; filename=\"" + file.name + "\"");
                Response.AddHeader("Content-Range", "bytes " + inits + "-" + stops + "/" + file.size);
                Response.AddHeader("Content-Length", stops - inits + 1);
                if (file.size <= 4096000) {
                    binstr = stream.Read(file.size);
                    Response.BinaryWrite(binstr);
                    Response.Flush();
                } else {
                    while (!stream.EOS) {
                        binstr = stream.Read(4096000);
                        Response.BinaryWrite(binstr);
                        Response.Flush();
                    }
                }
                stream.close();
                stream = null;
            } else {
                this.assign('content', '请求参数不合法');
                this.assign("upath", upath);
                this.display('Home:Dowload');
            }
        } else {
            this.assign('content', '该文件为空不能下载');
            this.assign("upath", upath);
            this.display('Home:Dowload');
        }
    } else {
        this.assign('content', '文件不存在');
        this.assign("upath", upath);
        this.display('Home:Dowload');
    }
});
/**
 * [查看图片]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:18:37+0800
 * @param    {[type]}                 ){    var filepath      [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("ShowImage", function() {
    var filepath = F.decode(F.get('Path'));
    var upaths = IO.parent(filepath);
    var upath = (!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths)) ? Mo.U('Home/Index', 'Path=' + F.encode(upaths)) : Mo.U('Home/Drive'); //生成上级路径信息
    if (!is_empty(filepath) && IO.is(filepath) && IO.file.exists(filepath)) {
        var file = IO.file.get(filepath);
        if (F.string.endsWith(file.type, '图像')) {
            var suffix = F.string.matches(file.type, /^\w+/ig);
            var last = !is_empty(suffix[0][0]) ? suffix[0][0].toLocaleLowerCase() : 'png';
            var filebin = IO.file.readAllBytes(filepath);
            Response.AddHeader("Content-Type", "image/" + last);
            var stream = new ActiveXObject("ADODB.Stream"); //解决限制
            stream.Open();
            stream.Type = 1;
            stream.LoadFromFile(filepath);
            if (file.size <= 4096000) {
                Response.BinaryWrite(stream.Read());
                Response.Flush();
            } else {
                while (!stream.eos) {
                    binstr = stream.Read(4096000);
                    Response.BinaryWrite(binstr);
                    Response.Flush();
                }
            }
            stream.close();
            stream = null;
        } else {
            this.assign('content', '该文件不是图片，请下载后查看');
            this.assign("upath", upath);
            this.display('Home:ShowImage');
        }
    } else {
        this.assign('content', '文件不存在');
        this.assign("upath", upath);
        this.display('Home:ShowImage');
    }
});
/**
 * [编辑文件]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:18:43+0800
 * @param    {[type]}                 ){    var charset,content,info;   var filepath [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("Edit", function() {
    var charset, content, info;
    var filepath = F.decode(F.get('Path'));
    var charsetint = F.get.int("CharSet", 1);
    var upaths = IO.parent(filepath);
    var upath = (!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths)) ? Mo.U('Home/Index', 'Path=' + F.encode(upaths)) : Mo.U('Home/Drive'); //生成上级路径信息
    if (!is_empty(filepath) && IO.is(filepath) && IO.file.exists(filepath)) {
        var file = IO.file.get(filepath);
        if (file.size < 1024000) {
            charset = CharSetTest(charsetint);
            if (is_post()) {
                var postcontent = F.post('content');
                if (charsetint!=1) {
                    if (IO.file.writeAllText(filepath, postcontent, charset)) {
                        info = {
                            'info': '文件编辑保存成功',
                            'status': 1
                        };
                    } else {
                        info = {
                            'info': '文件编辑保存失败',
                            'status': 0
                        };
                    }
                }else{//去除utf-8的BOM头
                    var nobom = require("WriteNoBom");
                    var stream = new nobom(charset);
                    stream.WriteText(postcontent);
                    if (stream.SaveToFile(filepath, 2)==true) {
                     info = {
                        'info': '文件编辑保存成功',
                        'status': 1
                    };
                } else {
                    info = {
                        'info': '文件编辑保存失败',
                        'status': 0
                    };
                }
                stream.Close();
            }
        }
        content = F.encodeHtml(IO.file.readAllText(filepath, charset));
    } else {
        content = '文件内容超过1Mb，请下载后编辑';
    }
} else {
    content = '读取文件不存在';
}
this.assign('hashid', F.guid("N"));
this.assign('filepath', filepath);
this.assign('charset', charsetint);
this.assign("info", info);
this.assign("content", content);
this.assign("upath", upath);
this.display('Home:Edit');
});
/**
 * [重命名]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:18:49+0800
 * @param    {[type]}                 ){    var content,info;   var filepath [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("RName", function() {
    var content, info;
    var filepath = F.decode(F.get('Path'));
    var upaths = IO.parent(filepath);
    var upath = (!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths)) ? Mo.U('Home/Index', 'Path=' + F.encode(upaths)) : Mo.U('Home/Drive'); //生成上级路径信息
    if (!is_empty(filepath) && IO.is(filepath) && (IO.file.exists(filepath) || IO.directory.exists(filepath))) {
        if (is_post()) {
            var newnames = F.post('newname');
            if (!is_empty(newnames) && !F.string.test(newnames, /[\/|\\|\:|\*|\?|\"|\<|\>|\|]/g)) { //"//为了好看
                var newname = IO.build(upaths, newnames);
                if (IO.file.exists(filepath)) { //
                    if (IO.file.move(filepath, newname) !== false) {
                        info = {
                            'info': '文件重命名成功',
                            'status': 1
                        };
                        F.session("__error", info);
                        F.goto(Mo.U('Home/RName', 'Path=' + F.encode(newname)));
                        F.exit();
                    } else {
                        info = {
                            'info': '文件重命名失败',
                            'status': 0
                        };
                    }
                } else if (IO.directory.exists(filepath)) {
                    if (IO.directory.move(filepath, newname) !== false) {
                        info = {
                            'info': '文件夹重命名成功',
                            'status': 1
                        };
                        F.session("__error", info);
                        F.goto(Mo.U('Home/RName', 'Path=' + F.encode(newname)));
                        F.exit();
                    } else {
                        info = {
                            'info': '文件夹重命名失败',
                            'status': 0
                        };
                    }
                } else {
                    info = {
                        'info': '未知错误',
                        'status': 0
                    };
                }
            } else {
                info = {
                    'info': '新的文件或文件夹名称为空或存在非法字符',
                    'status': 0
                };
            }
        }
    } else {
        content = '目标文件或文件夹不存在';
    }
    this.assign('filepath', filepath);
    this.assign("info", info);
    this.assign("content", content);
    this.assign("upath", upath);
    this.display('Home:RName');
});
/**
 * [删除文件/文件夹]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:18:54+0800
 * @param    {[type]}                 ){    var content,info;   var filepath [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("Del", function() {
    var content, info;
    var filepath = F.decode(F.get('Path'));
    var upaths = IO.parent(filepath);
    var upath = (!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths)) ? Mo.U('Home/Index', 'Path=' + F.encode(upaths)) : Mo.U('Home/Drive'); //生成上级路径信息
    if (!is_empty(filepath) && IO.is(filepath) && (IO.file.exists(filepath) || IO.directory.exists(filepath))) {
        if (is_post()) {
            if (IO.file.exists(filepath)) {
                if (IO.file.del(filepath) !== false) {
                    info = {
                        'info': '文件删除成功',
                        'status': 1
                    };
                } else {
                    info = {
                        'info': '文件删除失败',
                        'status': 0
                    };
                }
            } else if (IO.directory.exists(filepath)) {
                if (IO.directory.del(filepath) !== false) {
                    info = {
                        'info': '文件夹删除成功',
                        'status': 1
                    };
                } else {
                    info = {
                        'info': '文件夹删除失败',
                        'status': 0
                    };
                }
            } else {
                info = {
                    'info': '未知错误',
                    'status': 0
                };
            }
        }
    } else {
        content = '目标文件或文件夹不存在';
    }
    this.assign('filepath', filepath);
    this.assign("info", info);
    this.assign("content", content);
    this.assign("upath", upath);
    this.display('Home:Del');
});
/**
 * [创建文件/文件夹]
 * @Author   ZiShang520
 * @DateTime 2015-12-09T23:43:44+0800
 * @param    {[type]}                 ){    var content,info;   var filepath [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("Create", function() {
    var content, info;
    var filepath = F.decode(F.get('Path'));
    // var upaths=IO.parent(filepath);
    var upath = (!is_empty(filepath) && IO.is(filepath) && IO.directory.exists(filepath)) ? Mo.U('Home/Index', 'Path=' + F.encode(filepath)) : Mo.U('Home/Drive'); //生成上级路径信息
    if (!is_empty(filepath) && IO.is(filepath) && IO.directory.exists(filepath)) {
        if (is_post()) {
            var type = F.post.int('type', 0);
            var newfilepath = F.post('newnames');
            if (!is_empty(newfilepath) && !F.string.test(newfilepath, /[\/|\\|\:|\*|\?|\"|\<|\>|\|]/)) { //"//为了好看
                var newnames = IO.build(filepath, newfilepath); //
                if (!IO.file.exists(newnames) && !IO.directory.exists(newnames)) { //
                    if (type == 1) {
                        if (IO.directory.create(newnames)) {
                            info = {
                                'info': '文件夹创建成功',
                                'status': 1
                            };
                        } else {
                            info = {
                                'info': '文件夹创建失败',
                                'status': 0
                            };
                        }
                    } else if (type == 2) {
                        var fp = IO.file.open(newnames);
                        if (IO.file.flush(fp)) {
                            info = {
                                'info': '文件创建成功',
                                'status': 1
                            };
                        } else {
                            info = {
                                'info': '文件创建失败',
                                'status': 0
                            };
                        }
                        IO.file.close(fp);
                    } else {
                        info = {
                            'info': '参数错误',
                            'status': 0
                        };
                    }
                } else {
                    content = '目标文件或文件夹已存在';
                }
            } else {
                content = '需要创建文件或文件夹名称不规范';
            }
        }
    } else {
        content = '目录文件夹不存在';
    }
    this.assign('filepath', filepath);
    this.assign("info", info);
    this.assign("content", content);
    this.assign("upath", upath);
    this.display('Home:Create');
});
/**
 * [目录详情]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:18:58+0800
 * @param    {[type]}                 ){    var directory,content;  var filepath [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("Directory", function() {
    var directory, content;
    var filepath = F.decode(F.get('Path'));
    var upaths = IO.parent(filepath);
    var upath = (!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths)) ? Mo.U('Home/Index', 'Path=' + F.encode(upaths)) : Mo.U('Home/Drive'); //生成上级路径信息
    if (!is_empty(filepath) && IO.is(filepath) && IO.directory.exists(filepath)) {
        try {
            directory = IO.directory.get(filepath);
        } catch (ex) {
            content = '没有权限';
        }
    } else {
        content = '目标文件夹不存在';
    }
    this.assign("directory", directory);
    this.assign("content", content);
    this.assign("upath", upath);
    this.display('Home:Directory');
});
/**
 * [文件详情]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:19:04+0800
 * @param    {[type]}                 ){    var file,content;   var filepath [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("File", function() {
    var file, content;
    var filepath = F.decode(F.get('Path'));
    var upaths = IO.parent(filepath);
    var upath = (!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths)) ? Mo.U('Home/Index', 'Path=' + F.encode(upaths)) : Mo.U('Home/Drive'); //生成上级路径信息
    if (!is_empty(filepath) && IO.is(filepath) && IO.file.exists(filepath)) {
        try {
            file = IO.file.get(filepath);
        } catch (ex) {
            content = '没有权限';
        }
    } else {
        content = '目标文件不存在';
    }
    this.assign("file", file);
    this.assign("content", content);
    this.assign("upath", upath);
    this.display('Home:File');
});
/**
 * [终端模拟]
 * @Author   ZiShang520
 * @DateTime 2015-12-17T23:18:55+0800
 * @param    {ActiveXObject}          ){    dump(IO.build('E:'));   var shell [description]
 * @return   {[type]}                     [description]
 */
 HomeController.extend("Shell", function() {
    var content, shell;
    var filepath = F.decode(F.get('Path'));
    var upath = (!is_empty(filepath) && IO.is(filepath) && IO.directory.exists(filepath)) ? Mo.U('Home/Index', 'Path=' + F.encode(filepath)) : Mo.U('Home/Drive'); //生成上级路径信息
    if (is_post()) {
        shell = F.post('shell');
        if (!is_empty(shell)) {
            var cmd = '%COMSPEC% /c ' + F.string.trim(shell);
            var S = new ActiveXObject("WScript.Shell");
            var X = S.exec(cmd);
            content = X.StdOut.ReadAll() + X.StdErr.ReadAll();
        }
    }
    this.assign("shell", shell);
    this.assign("content", content);
    this.assign("filepath", filepath);
    this.assign("upath", upath);
    this.display('Home:Shell');
});
/**
 * [解压缩]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:19:09+0800
 * @param    {[type]}                 ){    dump(IO.build('E:'));} [description]
 * @return   {[type]}                                             [description]
 */
 HomeController.extend("Unzip", function() {
    var Zip = require("zip"); //引入zip组件
    var content,info;
    var filepath = F.decode(F.get('Path'));
    var upaths = IO.parent(filepath);
    var upath = (!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths)) ? Mo.U('Home/Index', 'Path=' + F.encode(upaths)) : Mo.U('Home/Drive'); //生成上级路径信息
    if (!is_empty(filepath) && IO.is(filepath) && IO.file.exists(filepath)) {
        var file = IO.file.get(filepath);
        var fp = IO.file.open(filepath,{forText:true,forRead:true});
        var txt = IO.file.read(fp,2);
        IO.file.close(fp);
        if (F.string.test(file.type, /zip/gi) && txt=='PK') {
            if (is_post()) {
                var unpath = !is_empty(F.post('unpath')) ? F.post('unpath') : upaths;
                try {
                    Zip.unZip(filepath, unpath, {
                        base64: true
                    });
                    info = {
                        'info': '文件解压成功',
                        'status': 1
                    };
                } catch (ex) {
                    info = {
                        'info': '文件解压失败:'+ex,
                        'status': 0
                    };
                }
            }
        } else {
            content = '该文件不是ZIP压缩文件，请确认文件类型';
        }
    } else {
        content = '目标文件不存在';
    }
    this.assign('info',info);
    this.assign("filepath", filepath);
    this.assign("upaths", upaths);
    this.assign("content", content);
    this.assign("upath", upath);
    this.display('Home:Unzip');
});

/**
 * dos
 * @Author   ZiShang520
 * @DateTime 2016-01-08T11:27:24+0800
 * @param    {String}                 ){                 if(is_ajax()){        Response.ContentType [description]
 * @return   {[type]}                     [description]
 */
 HomeController.extend("Dos",function(){
    if(is_ajax()){
        Response.ContentType = "application/json";//设置请求头
        var paths = F.decode(F.post('path'));//这。。。。
        if (!is_empty(paths) && IO.is(paths) && IO.directory.exists(paths)) {
            path = paths;
        } else {
            path = F.mappath("../");
        }
        var shell = F.post('shell');//提交的shell
        var drive = IO.drive(path);//啪啪啪
        var d=drive.path;//获取磁盘
        var hpath=F.replace(path, d , '');//
        hpath=hpath!=''?'cd '+hpath+'&':'';//获取目录
        if (!is_empty(shell)) {
            if (F.string.trim(shell)!='cmd') {
                var cmd = '%COMSPEC% /c ' + d + '&' + hpath + F.string.trim(shell) + '&echo [_s_DIR_g_]&cd&echo [_s_DIR_g_]';
                var S = new ActiveXObject("WScript.Shell");
                var X = S.exec(cmd);//执行
                content = X.StdOut.ReadAll();//获取返回内容
                cmderr=X.StdErr.ReadAll();//获取错误
                var c=F.string.matches(content,/\[_s_DIR_g_\]((?:.|[\r\n])*)\[_s_DIR_g_\]/i);//匹配
                var rm=!is_empty(c[0])?c[0]:'';//路径
                var p=!is_empty(c[1])?c[1]:path;//路径
                var p=str_replace(F.replace(p,/[\r\n]/ig,''));//去掉换行
                var s=str_replace(F.replace(content, rm , '')+cmderr);//核定内容
                F.echo('{"msg":"'+s+'","path":"'+p+'"}');//返回json到前台
            }else{
                F.echo('{"msg":"Microsoft Windows [版本 10.0.10586]\\r\\n(c) 2015 Microsoft Corporation。保留所有权利。","path":"'+str_replace(path)+'"}');//如果提交的是cmd防止循环调用
            }
        }else{
            F.echo('{"msg":"","path":"'+str_replace(path)+'"}');//没有数据就直接输出
        }
    }else{
        var paths = F.decode(F.get('Path'));
        if (!is_empty(paths) && IO.is(paths) && IO.directory.exists(paths)) {
            filepath = paths;
        } else {
            filepath = F.mappath("../");
        }
        var upaths = IO.parent(filepath);
        var upath = (!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths)) ? Mo.U('Home/Index', 'Path=' + F.encode(upaths)) : Mo.U('Home/Drive'); //生成上级路径信息
        this.assign("filepath", filepath);
        this.assign("upath", upath);
        this.display('Home:Dos');
    }
});

/**
 * 空方法
 * @Author   ZiShang520
 * @DateTime 2016-01-09T21:07:00+0800
 * @param    {[type]}                 name){                 F.echo("错误：未定义" + name + "方法");} [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("empty", function(name){
    F.goto(Mo.U('Home/Index'));
});

</script>
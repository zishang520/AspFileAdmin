<script language="jscript" runat="server">
/**
 * [HomeController description]
 * @type {[type]}
 */
 HomeController = IController.create();
/**
 * [description]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:18:09+0800
 * @param    {[type]}                 ){	var path,p;	var   gpath [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("Index", function(){
 	var path,p;
 	var gpath=F.decode(F.get('Path'));
 	if (!is_empty(gpath) && IO.is(gpath) && IO.directory.exists(gpath)) {
 		path=gpath;
 	}else{
 		path=F.mappath("../");
 	}
 	var upaths=IO.parent(path);
	var upath=(!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths))?Mo.U('Home/Index','Path='+F.encode(upaths)):Mo.U('Home/Drive');//生成上级路径信息
	var directories=[];
	IO.directory.directories(path,function(directorie){
		directories.push(directorie);
	});
	var directories = (directories.length!=0)?directories:null;//文件夹列表
	var files=[];
	IO.directory.files(path,function(file){
		files.push(file);
	});
	var files = (files.length!=0)?files:null;//文件列表
	this.assign("files",files);
	this.assign("directories",directories);
	this.assign("upath",upath);
	this.assign("path",path);
	this.display('Home:Index');
});
/**
 * [description]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:18:18+0800
 * @param    {Array}                  ){	var drives        [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("Drive", function(){
 	var drives=[];
 	IO.drive.drives(function(drive){
 		drives.push(drive);
 	});
 	this.assign("drives",drives);
 	this.display('Home:Drive');
 });
/**
 * [description]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:18:23+0800
 * @param    {[type]}                 ){	var charset,content;	var filepath [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("Show", function(){
 	var charset,content;
 	var filepath=F.decode(F.get('Path'));
 	var upaths=IO.parent(filepath);
	var upath=(!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths))?Mo.U('Home/Index','Path='+F.encode(upaths)):Mo.U('Home/Drive');//生成上级路径信息
	if (!is_empty(filepath) && IO.is(filepath) && IO.file.exists(filepath)){
		var file=IO.file.get(filepath);
		if (file.size<1024000) {
			var charsetint=F.get.int("CharSet",1);
			charset=CharSetTest(charsetint);
			var fp = IO.file.open(filepath,{forText:true,forRead:true,encoding:charset});
			content = F.encodeHtml(IO.file.read(fp));
			IO.file.close(fp);
		}else{
			content = '文件内容超过1Mb，请下载后查看';
		}
	}else{
		content='读取文件不存在';
	}
	this.assign('filepath',filepath);
	this.assign("content",content);
	this.assign("upath",upath);
	this.display('Home:Show');
});
/**
 * [description]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:18:31+0800
 * @param    {[type]}                 ){	var filepath      [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("Dowload", function(){
 	var filepath=F.decode(F.get('Path'));
 	var upaths=IO.parent(filepath);
	var upath=(!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths))?Mo.U('Home/Index','Path='+F.encode(upaths)):Mo.U('Home/Drive');//生成上级路径信息
	if (!is_empty(filepath) && IO.is(filepath) && IO.file.exists(filepath)){
		var range=F.server('HTTP_RANGE'),inits,stops;
		var file=IO.file.get(filepath);
		if (!is_empty(range)) {
			var byt = F.string.matches(range,/bytes\=(\d+)?-(\d+)?/ig);
			if(byt.length>0){
				inits=!is_empty(byt[0][1])?parseInt(byt[0][1]):0;
				if (inits==0) {
					stops=file.size-1;
				}else if(inits>0 && is_empty(byt[0][2])){
					stops=file.size-1;
				}else{
					stops=(!is_empty(byt[0][2]) && inits<(parseInt(byt[0][2])))?parseInt(byt[0][2]):file.size-1;
				}
			}else{
				inits=0;
				stops=file.size-1;
			}
		}else{
			inits=0;
			stops=file.size-1;
		}
		if(stops<=file.size){
			Response.Buffer = true;//开启缓存完毕输出
			Response.Clear();//清除缓存
			var stream = new ActiveXObject("ADODB.Stream");//解决下载限制
			stream.Mode = 3;//读写模式
			stream.Type = 1;//二进制
			stream.Open();
			stream.LoadFromFile(filepath);
			stream.Position = inits;//流指针
			// stream.SetEOS = stops;
			Response.Status = "206 Partial Content";
			Response.ContentType = "application/octet-stream";
			Response.AddHeader('Accept-Ranges','bytes');
			Response.AddHeader("Content-Disposition","attachment; filename=\""+file.name+"\"");
			Response.AddHeader("Content-Range","bytes "+inits+"-"+stops+"/"+file.size);
			Response.AddHeader("Content-Length",stops-inits+1);
			if (file.size<=4096000) {
				binstr = stream.Read(stops);
				Response.BinaryWrite(binstr);
				Response.Flush();
			}else{
				while(!stream.EOS){
					binstr = stream.Read(4096000);
					Response.BinaryWrite(binstr);
					Response.Flush();
				}
			}
			stream.close();		
			stream = null;
		}else{
			this.assign('content','请求参数不合法');
			this.assign("upath",upath);
			this.display('Home:Dowload');
		}
	}else{
		this.assign('content','文件不存在');
		this.assign("upath",upath);
		this.display('Home:Dowload');
	}
});
/**
 * [description]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:18:37+0800
 * @param    {[type]}                 ){	var filepath      [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("ShowImage", function(){
 	var filepath=F.decode(F.get('Path'));
 	var upaths=IO.parent(filepath);
	var upath=(!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths))?Mo.U('Home/Index','Path='+F.encode(upaths)):Mo.U('Home/Drive');//生成上级路径信息
	if (!is_empty(filepath) && IO.is(filepath) && IO.file.exists(filepath)){
		var file=IO.file.get(filepath);
		if (F.string.endsWith(file.type,'图像')) {
			var suffix=F.string.matches(file.type,/^\w+/ig);
			var last=!is_empty(suffix[0][0])?suffix[0][0].toLocaleLowerCase():'png';
			var filebin=IO.file.readAllBytes(filepath);
			Response.AddHeader("Content-Type","image/"+last);
			var stream = new ActiveXObject("ADODB.Stream");//解决限制
			stream.Open();
			stream.Type = 1;
			stream.LoadFromFile(filepath);
			if (file.size<=4096000) {
				Response.BinaryWrite(stream.Read());
				Response.Flush();
			}else{
				while(!stream.eos){
					binstr = stream.Read(4096000);
					Response.BinaryWrite(binstr);
					Response.Flush();
				}
			}
			stream.close();
			stream = null;
		}else{
			this.assign('content','该文件不是图片，请下载后查看');
			this.assign("upath",upath);
			this.display('Home:ShowImage');
		}
	}else{
		this.assign('content','文件不存在');
		this.assign("upath",upath);
		this.display('Home:ShowImage');
	}
});
/**
 * [description]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:18:43+0800
 * @param    {[type]}                 ){	var charset,content,info;	var filepath [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("Edit",function(){
 	var charset,content,info;
 	var filepath=F.decode(F.get('Path'));
 	var charsetint=F.get.int("CharSet",1);
 	var upaths=IO.parent(filepath);
	var upath=(!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths))?Mo.U('Home/Index','Path='+F.encode(upaths)):Mo.U('Home/Drive');//生成上级路径信息
	if (!is_empty(filepath) && IO.is(filepath) && IO.file.exists(filepath)){
		var file=IO.file.get(filepath);
		if (file.size<1024000) {
			charset=CharSetTest(charsetint);
			if (is_post()) {
				var postcontent=F.post('content');
				if(IO.file.writeAllText(filepath,postcontent,charset)){
					info = {'info':'文件编辑保存成功','status':1};
				}else{
					info = {'info':'文件编辑保存失败','status':0};
				}
			}
			var fp = IO.file.open(filepath,{forText:true,forRead:true,encoding:charset});
			content = IO.file.read(fp);
			IO.file.close(fp);
		}else{
			content = '文件内容超过1Mb，请下载后编辑';
		}
	}else{
		content='读取文件不存在';
	}
	this.assign('filepath',filepath);
	this.assign('charset',charsetint);
	this.assign("info",info);
	this.assign("content",content);
	this.assign("upath",upath);
	this.display('Home:Edit');
});
/**
 * [description]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:18:49+0800
 * @param    {[type]}                 ){	var content,info;	var filepath [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("RName",function(){
 	var content,info;
 	var filepath=F.decode(F.get('Path'));
 	var upaths=IO.parent(filepath);
	var upath=(!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths))?Mo.U('Home/Index','Path='+F.encode(upaths)):Mo.U('Home/Drive');//生成上级路径信息
	if (!is_empty(filepath) && IO.is(filepath) && (IO.file.exists(filepath) || IO.directory.exists(filepath))){
		if (is_post()) {
			var newnames=F.post('newname');
			if (!is_empty(newnames) && F.string.exp(newnames,/[\/|\\|\:|\*|\?|\"|\<|\>|\|]/)!=newnames) {//"//为了好看
				var newname=IO.build(upaths,newnames);
				if (IO.file.exists(filepath)) {//
					if(IO.file.move(filepath,newname)!==false){
						info = {'info':'文件重命名成功','status':1};
						F.session("__error",info);
						F.goto(Mo.U('Home/RName','Path='+F.encode(newname)));
						F.exit();
					}else{
						info = {'info':'文件重命名失败','status':0};
					}
				}else if (IO.directory.exists(filepath)) {
					if(IO.directory.move(filepath,newname)!==false){
						info = {'info':'文件夹重命名成功','status':1};
						F.session("__error",info);
						F.goto(Mo.U('Home/RName','Path='+F.encode(newname)));
						F.exit();
					}else{
						info = {'info':'文件夹重命名失败','status':0};
					}
				}else{
					info = {'info':'未知错误','status':0};
				}
			}else{
				info = {'info':'新的文件或文件夹名称为空或存在非法字符','status':0};
			}
		}
	}else{
		content='目标文件或文件夹不存在';
	}
	this.assign('filepath',filepath);
	this.assign("info",info);
	this.assign("content",content);
	this.assign("upath",upath);
	this.display('Home:RName');
});
/**
 * [description]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:18:54+0800
 * @param    {[type]}                 ){	var content,info;	var filepath [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("Del",function(){
 	var content,info;
 	var filepath=F.decode(F.get('Path'));
 	var upaths=IO.parent(filepath);
	var upath=(!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths))?Mo.U('Home/Index','Path='+F.encode(upaths)):Mo.U('Home/Drive');//生成上级路径信息
	if (!is_empty(filepath) && IO.is(filepath) && (IO.file.exists(filepath) || IO.directory.exists(filepath))){
		if (is_post()) {
			if (IO.file.exists(filepath)) {
				if(IO.file.del(filepath)!==false){
					info = {'info':'文件删除成功','status':1};
				}else{
					info = {'info':'文件删除失败','status':0};
				}
			}else if (IO.directory.exists(filepath)) {
				if(IO.directory.del(filepath)!==false){
					info = {'info':'文件夹删除成功','status':1};
				}else{
					info = {'info':'文件夹删除失败','status':0};
				}
			}else{
				info = {'info':'未知错误','status':0};
			}
		}
	}else{
		content='目标文件或文件夹不存在';
	}
	this.assign('filepath',filepath);
	this.assign("info",info);
	this.assign("content",content);
	this.assign("upath",upath);
	this.display('Home:Del');
});

HomeController.extend("Create",function(){
	var content,info;
	var filepath=F.decode(F.get('Path'));
	// var upaths=IO.parent(filepath);
	var upath=(!is_empty(filepath) && IO.is(filepath) && IO.directory.exists(filepath))?Mo.U('Home/Index','Path='+F.encode(filepath)):Mo.U('Home/Drive');//生成上级路径信息
	if (!is_empty(filepath) && IO.is(filepath) && IO.directory.exists(filepath)){
		if (is_post()) {
			var type=F.post.int('type',0);
			var newfilepath=F.post('newnames');
			if (!is_empty(newfilepath) && F.string.exp(newfilepath,/[\/|\\|\:|\*|\?|\"|\<|\>|\|]/)!=newfilepath){//"//为了好看
				var newnames=IO.build(filepath,newfilepath);//
				if(!IO.file.exists(newnames) && !IO.directory.exists(newnames)) {//
					if (type==1) {
						if (IO.directory.create(newnames)) {
							info = {'info':'文件夹创建成功','status':1};
						}else{
							info = {'info':'文件夹创建失败','status':0};
						}
					}else if(type==2){
						var fp=IO.file.open(newnames);
						if (IO.file.flush(fp)) {
							info = {'info':'文件创建成功','status':1};
						}else{
							info = {'info':'文件创建失败','status':0};
						}
						IO.file.close(fp);
					}else{
						info = {'info':'参数错误','status':0};
					}
				}else{
					content='目标文件或文件夹已存在';
				}
			}else{
				content='需要创建文件或文件夹名称不规范';
			}
		}
	}else{
		content='目录文件夹不存在';
	}
	this.assign('filepath',filepath);
	this.assign("info",info);
	this.assign("content",content);
	this.assign("upath",upath);
	this.display('Home:Create');
});
/**
 * [description]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:18:58+0800
 * @param    {[type]}                 ){	var directory,content;	var filepath [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("Directory",function(){
 	var directory,content;
 	var filepath=F.decode(F.get('Path'));
 	var upaths=IO.parent(filepath);
	var upath=(!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths))?Mo.U('Home/Index','Path='+F.encode(upaths)):Mo.U('Home/Drive');//生成上级路径信息
	if (!is_empty(filepath) && IO.is(filepath) && IO.directory.exists(filepath)){
		try{
			directory = IO.directory.get(filepath);
		}catch(ex){
			content='没有权限';
		}
	}else{
		content='目标文件夹不存在';
	}
	this.assign("directory",directory);
	this.assign("content",content);
	this.assign("upath",upath);
	this.display('Home:Directory');
});
/**
 * [description]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:19:04+0800
 * @param    {[type]}                 ){	var file,content;	var filepath [description]
 * @return   {[type]}                         [description]
 */
 HomeController.extend("File",function(){
 	var file,content;
 	var filepath=F.decode(F.get('Path'));
 	var upaths=IO.parent(filepath);
	var upath=(!is_empty(upaths) && IO.is(upaths) && IO.directory.exists(upaths))?Mo.U('Home/Index','Path='+F.encode(upaths)):Mo.U('Home/Drive');//生成上级路径信息
	if (!is_empty(filepath) && IO.is(filepath) && IO.file.exists(filepath)){
		try{
			file = IO.file.get(filepath);
		}catch(ex){
			content='没有权限';
		}
	}else{
		content='目标文件不存在';
	}
	this.assign("file",file);
	this.assign("content",content);
	this.assign("upath",upath);
	this.display('Home:File');
});
/**
 * [description]
 * @Author   ZiShang520
 * @DateTime 2015-10-29T10:19:09+0800
 * @param    {[type]}                 ){	dump(IO.build('E:'));} [description]
 * @return   {[type]}                                             [description]
 */
 HomeController.extend("test",function(){
 	dump(IO.build('E:'));
 });
</script>
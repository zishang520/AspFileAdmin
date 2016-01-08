<script language="jscript" runat="server">
ErrorController = IController.create(); //创建控制器，控制器名跟文件名相同
//定义控制器默认方法
ErrorController.extend("Index", function(name){
    F.echo("错误的请求!"); //输出"Error World!"，F.echo为系统方法，详情参考相关节点“F辅助函数库”
});
//定义其他方法
ErrorController.extend("Show", function(name){
    F.echo("I'm MAE!");
});
//定义控制器空方法
ErrorController.extend("empty", function(name){
    F.echo("错误：未定义" + name + "方法");
});
</script>
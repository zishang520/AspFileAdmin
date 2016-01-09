<script language="jscript" runat="server">
EmptyController = IController.create(); //定义空控制器类
EmptyController.extend("Index", function(actionName){
	Response.Status = "404 Not Found";
	F.echo("未找到控制器");
});
</script>
<%@Language="JSCRIPT" CodePage="65001"%>
<script language="jscript" runat="server" src="Mo/Mo.js"></script>
<script language="jscript" runat="server">
/*
** File: default.asp
** Usage: the entry.
** About:
**	support@mae.im
*/
define("MO_CHARSET","UTF-8");
define("MO_APP_NAME", "FileAdmin");
define("MO_APP", "FileAdmin");
define("MO_CORE", "Mo");
define("MO_DEBUG", true);
define("MO_PRE_LIB", "onstart");
define("MO_ERROR_REPORTING",E_ALL);
define("MO_DEBUG_MODE","APPLICATION");
define("MO_COMPILE_CACHE", false);
Mo.on("load", function(){
    IController = require("lib/dist.js").IController;
    IController.extend("empty", function(){
        Response.Status = "404 Not Found";
        F.echo("未找到方法");
    });
});
startup();
</script>
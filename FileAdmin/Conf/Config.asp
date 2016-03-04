<script language="jscript" runat="server">
	return {
		MO_DEBUG: false,
		MO_DEBUG_MODE : "DIRECT",
		MO_COMPILE_CACHE: true,
		// MO_TAG_LIB : "Test",
		MO_TEMPLATE_ENGINE : "views/view2.js",
		MO_ERROR_REPORTING : E_ERROR | E_WARNING,
		MO_ROUTE_MODE : "URL",
		MO_ROUTE_URL_EXT : "html", 
		/*静态路由，不遍历，直接检索*/
		MO_ROUTE_MAPS : {},
		/*动态路由，需遍历检查*/
		MO_ROUTE_RULES : [
		{
			LookFor : /^(\w+)\/(\w+)\/(\w+)\/(\w+)*$/i,
			SendTo : "$1/$2?$3=$4"
		},
		{
			LookFor : /^(\w+)\/(\w+)\/CharSet\/([1-3])\/Path\/(.*?)$/i,
			SendTo : "$1/$2?CharSet=$3&Path=$4"
		},
		{
			LookFor : /^Path\/(.*?)$/i,
			SendTo : "Home/Index?Path=$1"
		},
		{
			LookFor : /^(\w+)\/(\w+)$/i,
			SendTo : "$1/$2"
		}
		],
		/*ACCESS数据库配置*/
		MO_DATABASE_DB : {
			"DB_Type": "ACCESS",
			"DB_Path": "Public/data/GBqcBsFizy.mdb"
		},
		/*通用的数据库配置*/
		MO_DATABASE_DIST : {
			DB_Type:"", /* support ACCESS|MSSQL|MYSQL|SQLITE|OTHER,if DB_Type is OTHER,you must set 'DB_Connectionstring'*/
			DB_Connectionstring:"", /* enabled when DB_Type is 'OTHER' */
			DB_Path:"", /* enabled when DB_Type is 'ACCESS' or 'SQLITE'*/
			DB_Server:"",
			DB_Username:"",
			DB_Password:"",
			DB_Name:"",
			DB_Splitchars:["[","]"], /* use '`' when DB_Type is 'MYSQL' or 'SQLITE'*/
			DB_Version:"", /* for MSSQL,it can be 2005,2012...;for mysql it can be 3.51,5.1...*/
			DB_Owner:"dbo", /* for MSSQL */
			DB_TABLE_PERX:Mo.Config.Global.MO_TABLE_PERX		
		}
	};
</script>
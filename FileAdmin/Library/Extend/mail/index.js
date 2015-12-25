/*
** File: index.js
** Usage: use session at some special situation
** About:
**    zishang520@gmail.com
*/
var $mail=function (User,Pwd,Smtp,Bcc) {
    this.charset = 'UTF-8';
    this.nFrom = User; //发件人
    // this.nCc = ''; //抄送
    this.nBcc = Bcc; //密送
    this.nSmtp = Smtp; //smtp服务器
    this.nAuth = 1; //0匿名 1普通 2NTLM验证
    this.nPort = 25; //端口 默认25
    this.nUser = User; //用户名
    this.nPwd = Pwd; //密码
    this.nTimeout = 60; //超时
    this.nSsl = false; //是否开启ssl
    this.nSend = 2; // 1 使用Pickup发送  2使用端口发送
};
$mail.prototype.to = function(mail,title,body,Bodynum) {
    if (Bodynum == 1) {
         this.nTextBody = 'yes'; //纯文本
     } else {
         this.nHtmlBody = 'yes'; //html模式
     }
    this.nTo = mail; //收件人
    this.nSubject = title; //标题
    this.nBody = body; //内容
};
$mail.prototype.send = function() {
    try {
        var sTemp = 'http://schemas.microsoft.com/cdo/configuration/';
        var cdo = new ActiveXObject("cdo.message");
        cdo.Configuration.Fields.Item(sTemp + "sendusing") = this.nSend;//發送方式
        cdo.Configuration.Fields.Item(sTemp + "smtpserver") = this.nSmtp;//smtp服務器
        cdo.Configuration.Fields.Item(sTemp + "smtpserverport") = this.nPort-0;//端口
        cdo.Configuration.Fields.Item(sTemp + "sendusername") = this.nUser;//用戶名
        cdo.Configuration.Fields.Item(sTemp + "sendpassword") = this.nPwd;//密碼
        cdo.Configuration.Fields.Item(sTemp + "smtpauthenticate") = this.nAuth;//授權
        cdo.Configuration.Fields.Item(sTemp + "smtpconnectiontimeout") = this.nTimeout-0;//超時
        cdo.Configuration.Fields.Item(sTemp + "smtpusessl") = (this.nSsl)?true:false;//開啟或關閉ssl
        cdo.Configuration.Fields.Update();
        cdo.To = this.nTo;//收件人
        cdo.From = this.nFrom;//發件人
        cdo.Subject = (this.nSubject != '')?this.nSubject:'没有填写标题';//標題
        cdo.BodyPart.Charset = this.charset;//編碼
        // if (typeof this.nCc != 'undefined') cdo.CC = this.nCc; //抄送，这里不需要
        if (this.nBcc != '') cdo.BCC = this.nBcc; //密送，这里后期有用
        if (typeof this.nHtmlBody != 'undefined') {
            cdo.HtmlBody = '<meta http-equiv="Content-Type" content="text/html; charset=' + this.charset + '" />' + this.nBody;
        }
        if (typeof this.nTextBody != 'undefined') {
            cdo.TextBody = this.nBody;
            cdo.TextBodyPart.Charset = this.charset;
        }
        cdo.Send();
        cdo = null;
        return true;
    } catch(e) {
        return e;
    }
};
module.exports = $mail;
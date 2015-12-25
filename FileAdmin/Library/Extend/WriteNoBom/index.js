/**
 ** File: index.js
 ** Usage: use session at some special situation
 ** About:
 **    @var zishang520@gmail.com
 */
var $WriteNoBom = function(charset) {
    try {
        var stream = new ActiveXObject('Adodb.Stream');
        stream.Mode = 3;
        stream.Open();
        stream.Charset = charset;
        this.stream = stream;
        return true;
    } catch (e) {
        return e;
    }
};
/**
 * 代替Adodb.Stream的WriteText()方法。首次调用时会自动去掉BOM
 */
$WriteNoBom.prototype.WriteText = function(text, option) {
    try {
        option = option || 0;
        var stream = this.stream;
        // 流位置不在最开始（已有数据），直接写入
        if (stream.Position != 0) {
            stream.WriteText(text, option);
            return;
        }
        // 流位置在最开始，写入文本后需要去掉BOM
        // 写入首字符
        stream.WriteText(text.charAt(0));
        stream.SetEOS();
        // 二进制模式读出首字符的字节数据
        stream.Position = 0;
        stream.Type = 1;
        stream.Position = 3;
        var bs = stream.Read();
        // 移动首字符的字节数据至流开始位置，覆盖BOM
        stream.Position = 0;
        stream.Write(bs);
        stream.SetEOS();
        // 将流改回文本模式，写入余下的字符
        stream.Position = 0;
        stream.Type = 2;
        stream.Position = stream.Size;
        stream.WriteText(text.substr(1), option);
        return true;
    } catch (e) {
        return e;
    }
};
/**
 * 代替Adodb.Stream的SaveToFile()方法，输出前将流类型修改为二进制，避免再次输出BOM
 */
$WriteNoBom.prototype.SaveToFile = function(filename, option) {
    try {
        option = option || 1;
        var stream = this.stream;
        stream.Position = 0;
        stream.Type = 1;
        stream.SaveToFile(filename, option);
        stream.Type = 2;
        return true;
    } catch (e) {
        return e;
    }
};
$WriteNoBom.prototype.Close = function() {
    var stream = this.stream;
    stream.close();
}

module.exports = $WriteNoBom;

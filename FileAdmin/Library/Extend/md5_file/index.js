/**
 * [dechex 10进制转换为16进制]
 * @Author    ZiShang520@gmail.com
 * @DateTime  2016-06-23T14:06:10+0800
 * @copyright (c)                      ZiShang520 All           Rights Reserved
 * @param     {[type]}                 number     [description]
 * @return    {[type]}                            [description]
 */
var dechex = function(number) {
    if (number < 0) {
        number = 0xFFFFFFFF + number + 1;
    }
    return parseInt(number, 10).toString(16);
};
/**
 * [BigEndianHex 获取md5段]
 * @Author    ZiShang520@gmail.com
 * @DateTime  2016-06-23T14:06:37+0800
 * @copyright (c)                      ZiShang520 All           Rights Reserved
 * @param     {[type]}                 int        [description]
 */
var BigEndianHex = function(int) {
    var result = dechex(int);
    var b1, b2, b3, b4
    b1 = result.substr(6, 2); //tmd vb中的mid是1开始
    b2 = result.substr(4, 2);
    b3 = result.substr(2, 2);
    b4 = result.substr(0, 2);
    return b1 + b2 + b3 + b4;
};
/**
 * [$md5_file 获取文件md5]
 * @Author    ZiShang520@gmail.com
 * @DateTime  2016-06-23T14:22:13+0800
 * @copyright (c)                      ZiShang520 All           Rights Reserved
 * @param     {[type]}                 path       [description]
 * @return    {[type]}                            [description]
 */
var $md5_file = function(path) {
    var path = path || '';
    try {
        var W = new ActiveXObject('WindowsInstaller.Installer');
        var FileHAsh = W.FileHash(path, 0);
        var m = '';
        for (var i = 1; i <= FileHAsh.FieldCount; i++) {
            m += BigEndianHex(FileHAsh.IntegerData(i));
        }
        return m;
    } catch (e) {
        return false;
    }
};

module.exports = $md5_file;
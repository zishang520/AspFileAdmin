/**
 * @package js passhash
 * @mail zishang520@gmail.com
 * @version 0.1
 * itoa64;
 * iteration_count_log2;
 * portable_hashes;
 * random_state;
 */
var php_js = {};

function uniqid(prefix, more_entropy) {
    /**
     * 唯一id
     * @Author   ZiShang520
     * @DateTime 2016-01-14T09:56:11+0800
     * discuss at: http://phpjs.org/functions/uniqid/
     * original by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
     * revised by: Kankrelune (http://www.webfaktory.info/)
     * note: Uses an internal counter (in php_js global) to avoid collisio
     * @param    {[type]}                 prefix       [description]
     * @param    {[type]}                 more_entropy [description]
     * @return   {[type]}                              [description]
     */
    if (typeof prefix === 'undefined') {
        prefix = '';
    }

    var retId;
    var formatSeed = function(seed, reqWidth) {
        var seed = parseInt(seed, 10).toString(16); // to hex str
        if (reqWidth < seed.length) { // so long we split
            return seed.slice(seed.length - reqWidth);
        }
        if (reqWidth > seed.length) { // so short we pad
            return Array(1 + (reqWidth - seed.length)).join('0') + seed;
        }
        return seed;
    };
    // END REDUNDANT
    if (!php_js.uniqidSeed) { // init seed with big random int
        php_js.uniqidSeed = Math.floor(Math.random() * 0x75bcd15);
    }
    php_js.uniqidSeed++;

    retId = prefix; // start with prefix, add current milliseconds hex string
    retId += formatSeed(parseInt(new Date().getTime() / 1000, 10), 8);
    retId += formatSeed(php_js.uniqidSeed, 5); // add seed hex string
    if (more_entropy) {
        // for more entropy we add a float lower to 10
        retId += (Math.random() * 10).toFixed(8).toString();
    }

    return retId;
}
/**
 * phphash
 * @Author   ZiShang520
 * @DateTime 2016-01-14T11:30:19+0800
 * @param    {[type]}                 iteration_count_log2 [description]
 * @param    {[type]}                 portable_hashes      [description]
 */
function PasswordHash(iteration_count_log2, portable_hashes) {
    this.itoa64 = './0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    if (iteration_count_log2 < 4 || iteration_count_log2 > 31) {
        iteration_count_log2 = 8;
    }
    this.iteration_count_log2 = iteration_count_log2;

    this.portable_hashes = portable_hashes;
    this.random_state = F.timespan() + uniqid(Math.floor(Math.random() * 2147483648), true);
};

var phtotype = PasswordHash.prototype;
phtotype.get_random_bytes = function(count) {
    for (var i = 0; i < count; i += 16) {
        this.random_state = SHA1(md5(F.timespan() + this.random_state));
    }
    return Hex.parse(this.random_state.slice(0, count * 2));
};
phtotype.gensalt_private = function(input) {
    var output = '$p$';
    output += this.itoa64.substr(Math.min(this.iteration_count_log2 + 5, 30), 1);
    output += Base64.e(input);
    return output;
};
phtotype.crypt_private = function(password, setting) {
    var output = '*0';
    if (setting.substr(0, 2) == output)
        output = '*1';

    if (setting.substr(0, 3) != '$p$')
        return output;

    var count_log2 = this.itoa64.indexOf(setting.substr(3, 1));
    if (count_log2 < 7 || count_log2 > 30)
        return output;

    // var count = 1 << count_log2;
    var salt = setting.substr(4, 8);

    if (salt.length != 8)
        return output;

    var hash = md5(salt + password);
    // do {
    //    hash = md5(hash + password);
    // } while (--count);
    output = setting.substr(0, 12);
    output += Base64.e(Hex.parse(hash).slice(0, 16), 16);

    return output.replace(/\=/g, '');
};
phtotype.HashPassword = function(password) {
    var random = '';
    if (random.length < 6)
        random = this.get_random_bytes(6);
    var hash = this.crypt_private(password, this.gensalt_private(random));
    if (hash.length == 34)
        return hash;
    return '*';
};
phtotype.CheckPassword = function(password, stored_hash) {
    var hash = this.crypt_private(password, stored_hash);
    return hash == stored_hash;
};
module.exports = PasswordHash;

'use strict';
var USE_TYPEDARRAY = (typeof Uint8Array !== 'undefined') && (typeof Uint16Array !== 'undefined') && (typeof Uint32Array !== 'undefined');

var deflateRaw = require("gzip/deflate").deflateRaw;
var inflateRaw = require("gzip/inflate").inflateRaw;

exports.uncompressInputType = USE_TYPEDARRAY ? "uint8array" : "array";
exports.compressInputType = USE_TYPEDARRAY ? "uint8array" : "array";

exports.magic = "\x08\x00";
exports.compress = function(input, compressionOptions) {
    return deflateRaw(input, {
        level : compressionOptions.level || -1 // default compression
    });
};
exports.uncompress =  function(input) {
    return inflateRaw(input);
};

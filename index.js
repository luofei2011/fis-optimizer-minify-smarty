/**
 * @fileO fis-optimizer-minify-smarty
 * @author  luofeihit2010@gmail.com
 * https://www.vim.ren/
 */

'use strict';

var uglifyJS = require('uglify-js');
var uglifyCSS = require('uglifycss');

// from: https://github.com/garygchai/fis-optimizer-minify-html
var styleReg = /(<style(?:(?=\s)[\s\S]*?["'\s\w\/\-]>|>))([\s\S]*?)(<\/style\s*>|$)/ig;
var scriptReg = /(<script(?:(?=\s)[\s\S]*?["'\s\w\/\-]>|>))([\s\S]*?)(<\/script\s*>|$)/ig;

/**
 * 调用uglifycss压缩css
 * @param {string} text 输入
 * @return {string} 压缩后的css字符串
 */
function minifyCSS(text) {
    return uglifyCSS.processString(text, {
        maxLineLen: 0,
        expandVars: 0,
        cuteComments: true
    });
}

var superReg = /\{\%((?!\%\}).)*\%\}/g;
var superMap = [];
var superKeyPrefix = '_a_global_val_by_fis_';
var superKeyReg = /_a_global_val_by_fis_(\d+)/g;
function minifyJs(content) {
	content = content.replace(superReg, function (m) {
		return superKeyPrefix + (superMap.push(m) - 1);
	});

	return uglifyJS.minify(content, {
        fromString: true,
        warnings: true
    }).code
    .replace(superKeyReg, function (m, index) {
    	return superMap[index];
    });
}

module.exports = function(content, file, conf){
    //压缩内联css
    content = content.replace(styleReg, function(m, start_tag, cont, end_tag){
    	var parseCont = "";
    	try {
    		parseCont = minifyCSS(cont);

    	} catch(e) {
    		parseCont = cont;
    	}
        return start_tag + parseCont + end_tag;
    });

	//压缩内联js
    content = content.replace(scriptReg, function(m, start_tag, cont, end_tag){
    	var parseCont = "";
    	try {
    		parseCont = minifyJs(cont);
    	} catch(e) {
    		parseCont = cont;
    	}
    	superMap = [];
        return start_tag + parseCont + end_tag;
    });

    file.setContent(content);

    return content;
};
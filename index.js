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
 * 调用uglify-js插件压缩js字符串
 * @param {string} text 输入
 * @return {string} 压缩完毕后的js字符串
 */
function minifyJS(text) {
    text = __assignSmartyJS(text).replace(/({%)/g, '/**www**$1').replace(/(%})/g, '$1**www**/');
    return uglifyJS.minify(text, {
        fromString: true,
        warnings: true,
        output: {
            comments: function (node, comment) {
                var reCommentStart = /^\*www\*\*{%/;
                var reCommentEnd = /%}\*\*www\*$/;

                return reCommentStart.test(comment.value) && reCommentEnd.test(comment.value);
            }
        }
    }).code
    .replace(/"?\|\|\^_\^\|\|"?/g, '')
    .replace(/\/\*\*www\*\*{%/g, '{%')
    .replace(/%}\*\*www\*\*\/(?:\r?\n)?/g, '%}');
}

/**
 * @description 用于处理赋值语句后未添加引号的smarty语句
 * @param {string} text 输入
 * @return {string} result
 */
function __assignSmartyJS(text) {
    var reAssign = /[=:]\s*{%/;
    var result = '';
    var match = text.match(reAssign);
    var leftBrace;
    var rightBrace;

    if (match) {
        leftBrace = text.indexOf('{%', match.index);
        rightBrace = text.indexOf('%}', match.index);

        // special hack
        // 解决在字符串中出现的={%%}情况
        if (rightBrace !== -1 && /^\s*[,;\r\n]/.test(text.substring(rightBrace + 2))) {
            result += text.substring(0, leftBrace);
            // TODO 这里最好还原 -- fixed at: 2015-07-01
            result += text.substring(leftBrace, rightBrace + 2)
                      .replace(/("|')/g, '\\$1')
                      .replace(/({%)/, '"||^_^||$1')
                      .replace(/(%})/, '$1||^_^||"');

            text = text.substring(rightBrace + 2);
            result += __assignSmartyJS(text);
        }
        else {
            result += text;
            console.log('[error] 不合法的smarty赋值语句，在' + match[0]);
        }
    }
    else {
        result += text;
    }

    return result;
}

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
    		parseCont = minifyJS(cont);
    	} catch(e) {
    		parseCont = cont;
    	}
        return start_tag + parseCont + end_tag;
    });

    file.setContent(content);

    return content;
};
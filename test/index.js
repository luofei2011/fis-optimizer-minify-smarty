var fis = require('../index');
var fs = require('fs');

var content = fs.readFileSync('./test.tpl', 'utf8');

fis(content, {
	setContent: function (text) {
		fs.writeFileSync('tmp.tpl', text, 'utf8');
	}
}, {});
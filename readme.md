# fis-optimizer-minify-smarty

压缩tpl文件中的内联css和js代码（主要是针对含有smarty变量的情况，不含smarty变量可自行选择更nb的插件）

### 功能

自用于压缩含有smarty变量（js中的赋值类语句）的内联js，不支持{%if%}、{%foraech%}这样的非赋值语句。

### 安装

```
npm install -g fis-optimizer-minify-smarty
```

### 配置

```
// fis-conf.js
fis.match('*.tpl', {
	optimizer: fis.plugin('minify-smarty')
});
```
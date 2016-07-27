{%include file="../common/widget_functions.tpl" inline%}
{%$orderMap = [
    'lastactivity' => '更新时间',
    'priority' => '优先级',
    'duedate' => '截止日期'
]%}
<style>body{margin:0}div{padding:10px;line-height:1.5;color:#fff;font-size:14px}</style>
<div class="task-container flexbox">
    <div class="flexbox-item">
        {%if $smarty.get.tab == 'mp' && $smarty.get.t != 'all'%}
        <div class="task-header">
            <span class="task-header-name">{%$tplData.projectName%}{%if $tplData.targetName%}<em> - {%$tplData.targetName%}</em>{%/if%}</span>
            <span class="task-header-func">
                <span class="icon-clipboard common-copy-list" title="点击复制固定链接"></span>
            </span>
        </div>
        {%/if%}
        <div class="task-selector flexbox">
            <span class="task-selector-item flexbox-auto{%if $type == 'list'%} active{%/if%}" data-type="list">列表</span>
            <span class="task-selector-item flexbox-auto{%if $type == 'table'%} active{%/if%}" data-type="table">表格</span>
            {%if isset($get.t) && $get.t == 'p'%}
            <span class="task-selector-item flexbox-auto{%if $type == 'stream'%} active{%/if%}" data-type="stream">动态</span>
            {%/if%}
            <span class="task-selector-item flexbox-auto{%if $type == 'workload'%} active{%/if%}" data-type="workload">工作量</span>
        </div>
        {%if $type != 'stream'%}
        <div class="task-filter clearfix">
            <span class="task-filter-item task-filter-status{%if isset($condition.version) || (isset($condition.active) && $smarty.get.tab != 'at')%} in-filter{%/if%}">
                <span class="task-filter-status-title">{%if count($tplData.versions) != 1%}{%if isset($condition.version)%}{%$condition.version%}{%elseif isset($condition.active) && $smarty.get.tab != 'at'%}未关闭{%else%}全部{%/if%}{%else%}{%$tplData.versions[0]%}{%/if%}</span>
                <span class="icon-cancel"></span>
            </span>
            {%if $smarty.get.tab == 'mt' || $smarty.get.tab == 'at'%}
            <span class="task-filter-item task-filter-project{%if isset($condition.projectId)%} in-filter{%/if%}">
                {%if count($tplData.projectsInfo) != 1%}
                    {%if isset($condition.projectId)%}
                        {%$showProject = $tplData.projectsInfo[$condition.projectId]%}
                    {%else%}
                        {%$showProject = "全部"%}
                    {%/if%}
                {%else%}
                    {%$values = array_values($tplData.projectsInfo)%}
                    {%$showProject = $values[0]%}
                {%/if%}
                <span class="task-filter-project-title" title="{%$showProject%}">项目: {%$showProject%}</span>
                <span class="icon-cancel"></span>
            </span>
            {%else%}
            <span class="task-filter-item task-filter-to{%if isset($condition.taskOwner)%} in-filter{%/if%}">
                <span class="task-filter-to-title">To:{%if count($tplData.owners) != 1%}{%if isset($condition.taskOwner)%}{%$condition.taskOwner%}{%else%}All{%/if%}{%else%}{%$tplData.owners[0]%}{%/if%}</span>
                <span class="icon-cancel"></span>
            </span>
            {%/if%}
            <!--span class="task-filter-item task-filter-detail">
                <span class="glyphicon glyphicon-filter"></span>
            </span-->
            <span class="task-filter-item task-filter-level">
                <span class="icon-down"></span>
                <span class="task-filter-level-title">按{%if isset($condition.orderby)%}{%$orderMap[$condition.orderby]%}{%else%}更新时间{%/if%}</span>
            </span>
        </div>
        {%/if%}
        <div class="task-content">
        {%if $type == 'list'%}
        {%include file="../task/list.tpl" inline%}
        {%elseif $type == 'table'%}
        {%include file="../task/table.tpl" inline%}
        {%elseif $type == 'stream'%}
        {%include file="../task/stream.tpl" inline%}
        {%elseif $type == 'workload'%}
        {%include file="../task/timeline.tpl" inline%}
        {%/if%}
        </div>
    </div>
    {%if !($smarty.get.tab == 'mp' && $smarty.get.t == 'p') && $smarty.get.type == 'list' && !isset($smarty.get.tid)%}
    <div class="chart-container flexbox-none" style="width:40%">
    {%include file="../task/chart.tpl" inline%}
    </div>
    {%/if%}
</div>
<script>require(["menu","util","logic/observer","com/clipboard"],function(t,e,a,n){function i(t){t=$.extend({},o(),t||{}),a.trigger("load_list",{condition:t})}function o(){return $.localStorage.get("condition")||{}}function r(t){$.localStorage.isSet("condition."+t)&&$.localStorage.remove("condition."+t)}var s={%json_encode($tplData.owners)%},l={%json_encode($tplData.task_nums)%},c={%json_encode($tplData.projectsInfo)%},f=$(".task-filter-to"),d=e.getParam("tab");if("mt"===d||"at"===d){var u=[];c=$.isArray(c)?{}:c;for(var v in c)u.push({name:c[v],data:{id:v}});var w=$(".task-filter-project");(u.length>1||w.hasClass("in-filter"))&&w.on("click",function(){var e=$(this),a=e.offset(),n=new t({data:u,callback:function(t){var e=$(this).data("id");i({projectId:e})}});return n.updatePosition(a.left,a.top+e.height()),!1}).on("click",".icon-cancel",function(){return w.removeClass("in-filter").find(".task-filter-project-title").text("项目: 全部"),r("projectId"),i(),!1})}if(s.length>1||f.hasClass("in-filter")){var p=[];s.forEach(function(t){p.push({name:t})}),f.on("click",function(){var e=$(this),a=e.offset(),n=new t({data:p,callback:function(t){e.addClass("in-filter").find(".task-filter-to-title").text("To:"+t),i({taskOwner:t})}});return n.updatePosition(a.left,a.top+e.height()),!1}).on("click",".icon-cancel",function(){var t=$(this).closest(".task-filter-to");return t.removeClass("in-filter").find(".task-filter-to-title").text("To:All"),r("taskOwner"),i(),!1})}var m=$(".task-filter-status"),k={%json_encode($tplData.versions)%};if(k.length>1||m.hasClass("in-filter")){var h=[];k.forEach(function(t){h.push({name:t})}),m.on("click",function(){var e=$(this),a=e.offset(),n=new t({data:h,callback:function(t){m.addClass("in-filter").find(".task-filter-status-title").text(t);var e={};r("version"),r("active"),"未关闭"===t?e.active="yes":e.version=t,i(e)}});return n.updatePosition(a.left,a.top+e.height()),!1}).on("click",".icon-cancel",function(){return m.removeClass("in-filter").find(".task-filter-status-title").text("全部"),r("version"),r("active"),i(),!1})}var g=$(".task-filter-level");g.on("click",function(){var e=$(this),a=e.offset(),n=new t({data:[{name:"更新时间",data:{type:"lastactivity"}},{name:"优先级",data:{type:"priority"}},{name:"截止日期",data:{type:"duedate"}}],callback:function(t){var e=$(this).data("type"),a={};g.find(".task-filter-level").text("按"+t),"lastactivity"!==e?a.orderby=e:r("orderby"),i(a)}});return n.updatePosition(a.left,a.top+e.height()),!1});var _=$(".mymsg-tips");"at"===e.getParam("tab")&&(l?_.removeClass("none"):_.addClass("none"),_.text(l));var y=$(".mytask-tips"),b={%json_encode($tplData.task_nums_active)%};"mt"===e.getParam("tab")&&(b?y.removeClass("none"):y.addClass("none"),y.text(b)),$(".common-copy-list").on("click",function(){var t=$.extend(e.getParams()||{},{tab:"mp",type:"list"});delete t.tid,n.copy(apms.baseURL+"manage?"+$.param(t),"文件夹")})});</script>

{%include file="../common/widget_functions.tpl" inline%}
{%$orderMap = [
    'lastactivity' => '更新时间',
    'priority' => '优先级',
    'duedate' => '截止日期'
]%}
<style>
body {
	margin: 0;
}
div {
	padding: 10px;
	line-height: 1.5;
	color: #fff;
	font-size: 14px;
}
</style>
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
<script>
require(['menu', 'util', 'logic/observer', 'com/clipboard'], function (Menu, _, observer, clipboard) {
    var owners = {%json_encode($tplData.owners)%};
    var taskNums = {%json_encode($tplData.task_nums)%};
    var projectsInfo = {%json_encode($tplData.projectsInfo)%};
    var $to = $('.task-filter-to');
    var tab = _.getParam('tab');

    // -- by project --
    if (tab === 'mt' || tab === 'at') {
        var projectConfig = [];
        projectsInfo = $.isArray(projectsInfo) ? {} : projectsInfo;
        for (var o in projectsInfo) {
            projectConfig.push({
                name: projectsInfo[o],
                data: {
                    id: o
                }
            });
        }

        var $project = $('.task-filter-project');
        if (projectConfig.length > 1 || $project.hasClass('in-filter')) {
            $project.on('click', function () {
                var $this = $(this);
                var offset = $this.offset();
                var menu = new Menu({
                    data: projectConfig,
                    callback: function (name) {
                        var id = $(this).data('id');
                        filterTask({
                            projectId: id
                        });
                    }
                });

                menu.updatePosition(offset.left, offset.top + $this.height());
                return false;
            })
            .on('click', '.icon-cancel', function () {
                $project.removeClass('in-filter').find('.task-filter-project-title').text('项目: 全部');

                deleteStorage('projectId');
                filterTask();
                return false;
            });
        }
    }
    // -- end project --

    // --start filter--
    if (owners.length > 1 || $to.hasClass('in-filter')) {
        var data = [];
        owners.forEach(function (o) {
            data.push({name: o});
        });
        $to.on('click', function () {
            var $this = $(this);
            var offset = $this.offset();

            var menu = new Menu({
                data: data,
                callback: function (owner) {
                    $this.addClass('in-filter').find('.task-filter-to-title').text('To:' + owner);
                    filterTask({
                        taskOwner: owner
                    });
                }
            });

            menu.updatePosition(offset.left, offset.top + $this.height());
            return false;
        })
        .on('click', '.icon-cancel', function () {
            var $to = $(this).closest('.task-filter-to');
            $to.removeClass('in-filter').find('.task-filter-to-title').text('To:All');

            deleteStorage('taskOwner');
            filterTask();
            return false;
        });
    }

    // --version filter--
    var $version = $('.task-filter-status');
    var versions = {%json_encode($tplData.versions)%};
    if (versions.length > 1 || $version.hasClass('in-filter')) {
        var config = [];
        versions.forEach(function (v) {
            config.push({name: v});
        });
        $version.on('click', function () {
            var $this = $(this);
            var offset = $this.offset();

            var menu = new Menu({
                data: config,
                callback: function (version) {
                    $version.addClass('in-filter').find('.task-filter-status-title').text(version);
                    var condition = {};

                    deleteStorage('version');
                    deleteStorage('active');
                    if (version === '未关闭') {
                        condition.active = 'yes';
                    }
                    else {
                        condition.version = version;
                    }
                    filterTask(condition);
                }
            });
            menu.updatePosition(offset.left, offset.top + $this.height());
            return false;
        })
        .on('click', '.icon-cancel', function () {
            $version.removeClass('in-filter').find('.task-filter-status-title').text('全部');

            deleteStorage('version');
            deleteStorage('active');
            filterTask();
            return false;
        });
    }
    // --end--

    // --common--
    function filterTask(condition) {
        condition = $.extend({}, getStorage(), condition || {});
        observer.trigger('load_list', {
            condition: condition
        });
    }
    function getStorage() {
        return $.localStorage.get('condition') || {};
    }
    function deleteStorage(key) {
        $.localStorage.isSet('condition.' + key) && $.localStorage.remove('condition.' + key);
    }
    // --end common--
    // --end filter--
    // --start order--
    var $level = $('.task-filter-level');
    $level.on('click', function () {
        var $this = $(this);
        var offset = $this.offset();

        var menu = new Menu({
            data: [
                {
                    name: '更新时间',
                    data: {type: 'lastactivity'}
                },
                {
                    name: '优先级',
                    data: {type: 'priority'}
                },
                {
                    name: '截止日期',
                    data: {type: 'duedate'}
                }
            ],
            callback: function (name) {
                var type = $(this).data('type');
                var condition = {};

                $level.find('.task-filter-level').text('按' + name);

                if (type !== 'lastactivity') {
                    condition.orderby = type;
                }
                else {
                    deleteStorage('orderby');
                }

                filterTask(condition);
            }
        });

        menu.updatePosition(offset.left, offset.top + $this.height());
        return false;
    });
    // --end order--
    // 更新任务数量
    var $tips = $('.mymsg-tips');
    if (_.getParam('tab') === 'at') {
        if (taskNums) {
            $tips.removeClass('none');
        }
        else {
            $tips.addClass('none');
        }
        $tips.text(taskNums);
    }
    var $noneClosedTasks = $('.mytask-tips');
    var taskNumsActive = {%json_encode($tplData.task_nums_active)%};
    if (_.getParam('tab') === 'mt') {
        if (taskNumsActive) {
            $noneClosedTasks.removeClass('none');
        }
        else {
            $noneClosedTasks.addClass('none');
        }
        $noneClosedTasks.text(taskNumsActive);
    }

    // 复制
    $('.common-copy-list').on('click', function () {
        var params = $.extend(_.getParams() || {}, {
            tab: 'mp',
            type: 'list'
        });
        delete params.tid;
        clipboard.copy(apms.baseURL + 'manage?' + $.param(params), '文件夹');
    });
});
</script>

<%--
  Created by IntelliJ IDEA.
  User: LWABCD
  Date: 2020/1/30
  Time: 13:22
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>政务公开</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/layui/css/layui.css" />
    <script type="text/javascript" src="${pageContext.request.contextPath}/resources/layui/layui.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/resources/js/jquery-1.11.3.min.js"></script>
</head>
<body style="padding:10px">
<!-- 搜索条件开始 -->
<fieldset class="layui-elem-field layui-field-title" style="margin-top: 20px;">
    <legend>查询条件</legend>
</fieldset>
<form class="layui-form" method="post" id="searchFrm">
    <div class="layui-form-item">
        <div class="layui-inline">
            <label class="layui-form-label">类型:</label>
            <div class="layui-input-block">
                <div class="layui-form">
                    <select name="ogtid" id="ogtid" lay-filter="ogtid">

                    </select>
                </div>
            </div>
        </div>
        <div class="layui-inline">
            <label class="layui-form-label">标题</label>
            <div class="layui-input-inline">
                <input type="text" name="title"  autocomplete="off" class="layui-input">
            </div>
        </div>
        <div class="layui-inline">
            <label class="layui-form-label">开始时间:</label>
            <div class="layui-input-inline">
                <input type="text" name="startTime" id="startTime" readonly="readonly"  autocomplete="off" class="layui-input">
            </div>
        </div>
        <div class="layui-inline">
            <label class="layui-form-label">结束时间:</label>
            <div class="layui-input-inline">
                <input type="text" name="endTime" id="endTime" readonly="readonly"  autocomplete="off" class="layui-input">
            </div>
        </div>
        <div class="layui-inline">
            <button type="button" class="layui-btn layui-btn-normal  layui-icon layui-icon-search" id="doSearch">查询</button>
            <button type="reset" class="layui-btn layui-btn-warm  layui-icon layui-icon-refresh">重置</button>
        </div>
    </div>
</form>

<!-- 数据表格开始 -->
<table class="layui-hide" id="userTable" lay-filter="userTable"></table>
<div id="page"></div>
<div style="display: none;" id="userToolBar">
    <button type="button" class="layui-btn layui-btn-sm" lay-event="add">添加公开内容</button>
    <button type="button" class="layui-btn layui-btn-danger layui-btn-sm" lay-event="deleteBatch">批量删除</button>
</div>
<div  id="userBar" style="display: none;">
    <a class="layui-btn layui-btn-xs" lay-event="detail">查看</a>
    <a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="del">删除</a>
</div>
<!-- 数据表格结束 -->

<script>
    
    layui.use([ 'jquery', 'layer', 'form', 'table','laydate','laypage','upload','element'], function() {
        var $ = layui.jquery;
        var layer = layui.layer;
        var form = layui.form;
        var table = layui.table;
        var laydate = layui.laydate;
        var laypage = layui.laypage;
        var upload = layui.upload;
        var element = layui.element;

        //渲染时间
        laydate.render({
            elem:'#startTime',
            type:'datetime'
        });
        laydate.render({
            elem:'#endTime',
            type:'datetime'
        });

        //渲染数据表格
        var tableIns = table.render({
            elem: '#userTable'   //渲染的目标对象
            , url: '/government/opengovernment/opengovernments' //数据接口
            , title: ''//数据导出来的标题
            , toolbar: "#userToolBar"   //表格的工具条
            , height: '500'
            , width: '80%'
            , cellMinWidth: 100 //设置列的最小默认宽度
            , page: true  //是否启用分页
            , limits: [5,10,20]
            , cols: [[   //列表数据
                {type: 'checkbox', fixed: 'left'}
                ,{field:'oid', title:'ID',align:'center',hide:true}
                ,{field: 'title', title: '标题', align: 'center', width: '500'}
                , {field: 'updatetime', title: '时间', align: 'center', width: '500',
                    templet: function (e) {
                        if (e.updatetime == null) {
                            return '';
                        } else {
                            return layui.util.toDateString(e.updatetime, "yyyy-MM-dd HH:mm:ss");
                        }
                    }
                }
                , {field: 'right', title: '操作', fixed: 'right', width: 177, align: 'center', toolbar: "#userBar"}
            ]]
        });

        form.on('select(ogtid)', function (obj) {
            search();
        });

        function search() {
            var ogtid=$("#ogtid").val();
            tableIns.reload({
                url:"/government/opengovernment/opengovernments",
                where:{
                    ogtid:ogtid
                }
            });
        }

        //模糊查询
        $("#doSearch").click(function(){
            var params=$("#searchFrm").serialize();
            tableIns.reload({
                url:"${ctx}/opengovernment/opengovernments?"+params,
                page:{curr:1}

            })
        });

        //监听头部工具栏事件
        table.on("toolbar(userTable)", function (obj) {
            switch (obj.event) {
                case 'add':
                    window.location.href="${pageContext.request.contextPath}/opengovernment/toopengovedit";
                    break;
                case 'deleteBatch':
                    deleteBatch();
            }
            ;
        })

        //监听行工具事件
        table.on('tool(userTable)', function(obj){
            var data = obj.data; //获得当前行数据
            var layEvent = obj.event; //获得 lay-event 对应的值（也可以是表头的 event 参数对应的值）
            if(layEvent === 'detail'){
                window.location.href="${pageContext.request.contextPath}/opengovernment/opengovdetail?oid="+data.oid;
            }else if(layEvent === 'del'){ //删除
                layer.confirm('真的删除行么', function(index){
                    //向服务端发送删除指令
                    $.ajax({
                        url:'/government/opengovernment/deleteopengov',
                        type:'post',
                        data:{'oid':data.oid},//向服务端发送删除的id
                        success:function(json){
                            if(json.code==1){
                                layer.alert("删除成功");
                                <%--window.location.href="${pageContext.request.contextPath}/announcement/toannouncement";--%>
                                search();
                            }
                            else{
                                layer.alert("删除失败");
                            }
                        }
                    });

                });
            }
        })

        //批量删除
        function deleteBatch(){
            //得到选中的数据行
            var checkStatus = table.checkStatus('userTable');
            var data = checkStatus.data;
            var params="";
            $.each(data,function(i,item){
                if(i==0){
                    params+="ids="+item.oid;
                }else{
                    params+="&ids="+item.oid;
                }
            });
            layer.confirm('真的删除选中的这些公开内容吗', function(index){
                //向服务端发送删除指令
                $.post("${ctx}/opengovernment/deleteBatchOpenGovernment",params,function(res){
                    layer.msg(res.msg);
                    //刷新数据 表格
                    tableIns.reload();
                })
            });
        }
    });

    $(document).ready(function () {
        $.ajax({
            url: '${pageContext.request.contextPath}/opengovernment/opengovtype',
            type: 'post',
            dataType: 'json',
            data: {}, // 要提交给服务端的数据
            success: function (data) { // 请求成功后如何处理结果?
                var len = data.data.length;
                var ogtid=$('#ogtid');
                for (var i = 0; i < len; i++) {
                    var opt = document.createElement('option');
                    opt.innerText = data.data[i].name;
                    opt.value = data.data[i].ogtid;
                    ogtid.append(opt);
                }

            }
        });
    });

</script>
</body>
</html>

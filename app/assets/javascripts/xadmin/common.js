
//时间 YYYY-mm-dd HH:MM:SS
$(function(){

  layui.use(['laydate', 'form'],
    function() {
      var laydate = layui.laydate;
      //执行一个laydate实例
      laydate.render({
        elem: '.laydate_time', //指定元素
        type: "datetime"
      });
  });

  layui.use(['form', 'layer','jquery'], function() {
    $ = layui.jquery;
    var form = layui.form,
    layer = layui.layer;

    //自定义验证规则
    form.verify({
      nikename: function(value) {
          if (value.length < 5) {
              return '昵称至少得5个字符啊';
          }
      },
      pass: [/(.+){6,12}$/, '密码必须6到12位'],
      repass: function(value) {
          if ($('#L_pass').val() != $('#L_repass').val()) {
              return '两次密码不一致';
          }
      }
    });
  });

})


function layer_tip(title, html, options={}){
  //关闭layer
  if(options["close"] != undefined){
    parent.layer.closeAll(options["close"])
  }
  opts = {
    title: title,
    shadeClose: true,
    shade: 0.8,
    skin: "common-class",
    closeBtn: 0,
    offset: "100px",
    btn: ["关闭"],
    content: html
  }
  time = parseInt(options["time"])
  if (!isNaN(time)){
    opts["time"] = time
  }
  var opt_list = ["time","area"]
  $.each(opt_list,function(i,item){
    if(item != undefined){
      opts[item] = options[item]
    }
  })
  parent.layer.open(opts);
}

function layer_page(title, url, options={}){
  layer.open({
    id: "layer_dialog",
    type: 2,
    title: title,
    shadeClose: true,
    shade: false,
    maxmin: true, //开启最大化最小化按钮
    area: ['893px', '600px'],
    content: url
  });
}
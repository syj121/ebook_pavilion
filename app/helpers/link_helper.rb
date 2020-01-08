module LinkHelper

  def link_to_blank(*args, &block)
    if block_given?
      options      = args.first || {}
      html_options = args.second || {}
      link_to_blank(capture(&block), options, html_options)
    else
      name         = args[0]
      options      = args[1] || {}
      html_options = args[2] || {}

      # override
      html_options.reverse_merge! target: '_blank'

      link_to(name, options, html_options)
    end
  end

  def link_to_void(*args, &block)
    link_to(*args.insert((block_given? ? 0 : 1), "javascript:void(0)"), &block)
  end

  def link_to_dialog(*args, &block)
    if block_given?
      options = args[0] || {}
      html_options = args[1] || {}
      html_options.deep_merge! onclick: "layer_page('', '#{options}')"
      link_to_void(html_options, &block)
    else
      name         = args[0]
      url      = args[1] || {}
      html_options = args[2] || {}

      generate_htmls(name, url, html_options[:method]) do |class_name, icon_block|
        html_options.deep_merge! onclick: "layer_page('#{name}', '#{url}')"
        html_options.deep_merge! class: class_name
        url = url.include?("?") ? "#{url}&back=#{request.fullpath}" : "#{url}?&back=#{request.fullpath}"
        link_to_void(html_options, &icon_block)
      end  
    end
  end

  #配置URL的icon、class，样式通用
  def link_to_icon(*args)
    #参数解析
    name = args[0]
    url = args[1]
    html_options = args[2] || {}

    generate_htmls(name, url, html_options[:method]) do |class_name, icon_block|
      html_options.deep_merge! class: class_name
      url = url.include?("?") ? "#{url}&back=#{request.fullpath}" : "#{url}?&back=#{request.fullpath}"
      link_to(url, html_options, &icon_block)
    end    
  end

  private
  #生成超链接的固定样式
  def generate_htmls(name, url, method_name)
    icons = {
      show: {icon: "&#xe6a4;", class: "layui-btn  layui-btn-normal"},
      new: {icon: "&#xe6b9;", class: "layui-btn"},
      edit: {icon: "&#xe69e;", class: "layui-btn "},
      destroy: {icon: "&#xe640;", class: "layui-btn layui-btn-danger "},
      pay: {icon: "&#xe702;", class: "layui-btn layui-btn-danger " },
      print: {icon: "&#xe6c9;", class: "layui-btn layui-btn-normal "},
      refresh: {icon: "&#xe6aa;", class: "layui-btn"}
    }
    icons.default = {icon: "", class: "layui-btn"}

    #url的固定配置信息
    aname = Rails.application.routes.recognize_path(url, method: method_name)[:action] #action的名字
    icon = icons[aname.to_sym]
    icon_name = icon[:icon]
    class_name = icon[:class]
    icon_block = lambda { ||  
      "<i class='iconfont'>#{icon_name}</i>#{name}".html_safe
    }
    if block_given?
      yield(class_name, icon_block)
    else
      {class_name: class_name, icon_name: "<i class='iconfont'>#{icon_name}</i>#{name}".html_safe}
    end
    
  end

end
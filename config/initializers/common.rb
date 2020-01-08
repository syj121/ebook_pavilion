# -*- encoding : utf-8 -*-

#设置全局可用变量
$settings = {site_name: "云书阁", frame: "xadmin"}

$settings.each do |k,v|
  define_method k do ||
    v
  end
end

#如果不设置默认值，页面展示，将展示时区，时间插件或将“输入”无效
Date::DATE_FORMATS[:default] = "%Y-%m-%d"
Time::DATE_FORMATS[:default] = "%Y-%m-%d %H:%M:%S"

class Time

  def index_day
    self.strftime('%Y%m%d').to_i
  end

  def index_month
    self.strftime('%Y%m').to_i
  end

end

class String
  def to_utf8
    encode("UTF-8", :undef => :replace, :replace => "?", :invalid => :replace).chars.select{|i| i.valid_encoding?}.join
  end
end

#active_record 通用方法
ActiveRecord::Base.send(:include, ActiveRecordPlus)
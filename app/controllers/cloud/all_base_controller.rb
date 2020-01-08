module Cloud
  class AllBaseController < ApplicationController
      
    layout "/#{$settings.frame}/background"

    # devise方法验证用户登录
    before_action :authenticate_user!

    # 为每个controller自动加载@object
    before_action :load_resource

    private
    def class_exists?(class_name)
      klass = Module.const_get(class_name)
      return klass.is_a?(Class)
    rescue NameError
      return false
    end

    def load_resource(class_name = nil, obj_name = nil)
      class_name ||= controller_name.singularize.classify
      return unless class_exists?(class_name)
      scope = class_name.constantize
      if ['new', 'create'].include?(params[:action].to_s)
        resource = scope.new
      elsif params[:id].to_i > 0
        resource = scope.find_by_id(params[:id])
        return rt_404 unless resource
      else
        resource = nil
      end
      obj_name ||= class_name.tableize.singularize
      instance_variable_set("@#{obj_name}", resource)
      # if resource
      #   # @stand_catalog.log_user = "#{current_user.id}|#{current_user.loginname}"
      #   instance_variable_get("@#{obj_name}").send("log_user=", "#{current_user.id}|#{current_user.loginname}")
      # end
    end
    
  end
end
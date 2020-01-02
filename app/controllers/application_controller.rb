class ApplicationController < ActionController::Base

  layout "#{$setting.frame}/foreground"
  
  # devise方法验证用户登录
  before_action :authenticate_user!

  # #如果没有配置这个，在注册的时候，会出现邮箱验证不通过的BUG
  before_action :configure_permitted_parametersod_name, if: :devise_controller?

  #自定义登录字段
  def configure_permitted_parametersod_name
    devise_parameter_sanitizer.permit(:sign_in) {|u| u.permit(:login_name, :password, :remember_me)}
    devise_parameter_sanitizer.permit(:sign_up) {|u|
    u.permit(:email, :login_name, :password, :password_confirmation)}
  end

end

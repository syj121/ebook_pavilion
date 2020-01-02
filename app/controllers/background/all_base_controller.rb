module Background
  class AllBaseController < ApplicationController
      
    layout "/#{$settings.frame}/background"

    # devise方法验证用户登录
    before_action :authenticate_user!
    
  end
end
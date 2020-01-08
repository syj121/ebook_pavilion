module Ebook
  class AllBaseController < Background::AllBaseController
      
    layout "/#{$settings.frame}/background"

    # devise方法验证用户登录
    before_action :authenticate_user!
    
  end
end
module Background 
  class UsersController < Background::AllBaseController

    def index
      @q = User.ransack(params[:q])
      @users = @q.result.page(params[:page])
    end

  end 
end
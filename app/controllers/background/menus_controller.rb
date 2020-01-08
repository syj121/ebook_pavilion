module Background 
  class MenusController < Background::AllBaseController

    def index
      @q = Menu.ransack(params[:q])
      @menus = @q.result.page(params[:page])
    end

    def create
      Menu.create(params[:menu].permit!)
      render json: {success: true}
    end

  end 
end
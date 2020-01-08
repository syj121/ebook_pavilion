module Cloud
  class CategoriesController < Cloud::AllBaseController

    def index
      @q = Category.ransack(params[:q])
      @categories = @q.result.page(params[:page])
    end

    def create
      Category.create(params[:category].permit!)
      redirect_to action: :index
    end

    def update
      @category.update(params[:category].permit!)
      redirect_to action: :index
    end

    def destroy
      @category.destroy
      redirect_to action: :index
    end

  end
end
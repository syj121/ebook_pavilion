module Ebook
  class WebCategoriesController < Ebook::AllBaseController

    def index
      @q = WebCategory.ransack(params[:q])
      @web_categories = @q.result.page(params[:page]).includes(:web_site, :category)
    end

    def create
      @web_category = WebCategory.create(params[:web_category].permit!)
      redirect_to params[:back]
    end

    def update
      @web_category.update(params[:web_category].permit!)
      redirect_to params[:back]
    end

  end
end
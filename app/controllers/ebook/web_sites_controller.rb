module Ebook
  class WebSitesController < Ebook::AllBaseController

    def index
      @q = WebSite.ransack(params[:q])
      @web_sites = @q.result.page(params[:page])
    end

    def create
      @web_site = WebSite.create(params[:web_site].permit!)
      redirect_to params[:back]
    end

    def update
      @web_site.update(params[:web_site].permit!)
      redirect_to params[:back]
    end

  end
end
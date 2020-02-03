module Ebook
  class WebChaptersController < Ebook::AllBaseController

    before_action :get_web_book

    def index
      @q = @web_book.chapters.ransack(params[:q])
      @web_chapters = @q.result.page(params[:page])
    end

    def refresh
      re = case params[:type]
      when "chapters"
        Snatch.chapters(@web_book, params)
      when "contents"
        Snatch.contents(@web_book, params)
      else
        "参数错误"
      end
      render js: "layer_tip('提示', '#{re}')"
    end

    def destroy
      @web_chapter.destroy
      redirect_to params[:back]
    end

    def show
      @contents = @web_chapter.contents.unscope(:order).order(position: :asc).page(params[:page]).per(1)
    end

    private
    def get_web_book
      @web_book = WebBook.find(params[:web_book_id])
    end

  end
end
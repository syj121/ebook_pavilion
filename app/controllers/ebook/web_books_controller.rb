module Ebook
  class WebBooksController < Ebook::AllBaseController

    def index
      @q = WebBook.ransack(params[:q])
      @web_books = @q.result.page(params[:page]).includes(:web_site)
    end

    def create
      @web_book = WebBook.create(params[:web_book].permit!)
      result = Snatch.book(@web_book, params)
      redirect_to params[:back]
    end

    def update
      @web_book.update(params[:web_book].permit!)
      redirect_to params[:back]
    end

    def destroy
      @web_book.destroy
      redirect_to params[:back]
    end

  end
end
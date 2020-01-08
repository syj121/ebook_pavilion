module Ebook
  class SnatchesController < Ebook::AllBaseController

    def categories
      result = Snatch.categories(params[:code])
      render js: "layer_tip('提示', '#{result}')"
    end

    def book
      web_book = WebBook.find(params[:book_id])
      result = Snatch.book(web_book)
      render js: "layer_tip('提示', '#{result}')"
    end

  end
end
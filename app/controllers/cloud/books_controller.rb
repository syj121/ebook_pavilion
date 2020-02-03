module Cloud
  class BooksController < Cloud::AllBaseController

    def index
      @q = Book.ransack(params[:q])
      @books = @q.result.page(params[:page]).includes(:category)
    end

    def create
      Book.create(params[:book].permit!)
      redirect_to action: :index
    end

    def update
      @book.update(params[:book].permit!)
      redirect_to action: :index
    end

    def destroy
      @book.destroy
      redirect_to action: :index
    end

  end
end
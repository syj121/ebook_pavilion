class AddIsInitToWebCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :web_categories, :is_init, :boolean, default: true, comment: "是否初始化，默认是初始化"
    add_column :web_book_contents, :position, :integer, default: 1, comment: "顺序"
  end
end

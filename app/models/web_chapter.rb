class WebChapter < ApplicationRecord

  belongs_to :web_book
  belongs_to :web_site

  has_many :contents, class_name: "WebBookContent"
  
  has_closure_tree


  #更新章节内容
  def fresh_contents
    Snatch.contents(web_book, {wcid: self.id})
  end
end
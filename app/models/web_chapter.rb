class WebChapter < ApplicationRecord

  belongs_to :web_book
  belongs_to :web_site

  has_many :contents, class_name: "WebBookContent"
  
  has_closure_tree
end
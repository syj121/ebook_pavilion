class WebBook < ApplicationRecord

  belongs_to :author, optional: true
  belongs_to :book, optional: true
  belongs_to :category, optional: true
  belongs_to :web_author, optional: true
  belongs_to :web_category, optional: true
  belongs_to :web_site
  has_many :chapters, class_name: "WebChapter"
end
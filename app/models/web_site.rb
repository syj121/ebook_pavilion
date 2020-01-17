class WebSite < ApplicationRecord
  
  has_many :web_categories, dependent: :restrict_with_error
  has_many :categories, through: :web_categories

  has_many :web_books, dependent: :restrict_with_error
  has_many :web_authors

end

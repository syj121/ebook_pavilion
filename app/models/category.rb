class Category < ApplicationRecord

  has_many :author_categories, dependent: :restrict_with_error
  has_many :authors, through: :author_categories

  has_many :book_categories, dependent: :restrict_with_error
  has_many :books, through: :book_categories

  has_many :web_categories, dependent: :restrict_with_error
  has_many :web_sites, through: :web_categories

  has_closure_tree
  
end
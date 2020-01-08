class Book < ApplicationRecord
  
  has_many :book_categories, dependent: :restrict_with_error
  has_many :categories, through: :book_categories

end

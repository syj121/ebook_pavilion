class Author < ApplicationRecord
  
  has_many :author_categories, dependent: :restrict_with_error
  has_many :categories, through: :author_categories

end

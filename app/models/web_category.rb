class WebCategory < ApplicationRecord
  
  belongs_to :web_site
  belongs_to :category, optional: true

  has_closure_tree

end

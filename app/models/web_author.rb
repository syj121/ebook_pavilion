class WebAuthor < ApplicationRecord

  belongs_to :web_site
  belongs_to :author, optional: true
end
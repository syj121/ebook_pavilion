class Permission < ApplicationRecord

  belongs_to :menu
  belongs_to :permision_group

end
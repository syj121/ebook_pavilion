class Role < ApplicationRecord

  has_many :role_users, dependent: :restrict_with_error
  has_many :users

  has_many :menu_roles
  has_many :menus, through: :menu_roles

  has_many :permision_groups, through: :menus
  has_many :permisions, through: :menus

end

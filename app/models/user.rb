class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :role_users, dependent: :destroy
  has_many :roles, through: :role_users

  belongs_to :current_role, class_name: "Role", foreign_key: "current_role_id"

end

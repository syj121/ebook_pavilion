class RoleUser < ApplicationRecord

  belongs_to :role, counter_cache: true
  belongs_to :user, counter_cache: true

end

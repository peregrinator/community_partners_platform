class UserRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :role

  default_scope -> { order('user_roles.position ASC') }
end

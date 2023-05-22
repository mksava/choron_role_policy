class User < ApplicationRecord
  include ChoronRolePolicy::DSL

  attribute :staff_role, default: "none"
  enum :staff_role, { "none" => :none, "admin" => :admin, "normarl" => :normarl }, prefix: true
  set_role :staff, role_method: :staff_role, all_allow: :is_super?

  attribute :admin_role, default: 0
  set_role :admin, enum: [:admin, :super_admin]

  def is_super?
    false
  end
end
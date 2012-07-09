class RolesPermissions < ActiveRecord::Migration
  def self.up
    create_table :roles_permissions, :id => false do |t|
      t.references :role, :permission
    end

  end

  def self.down
drop_table :roles_permissions
  end
end

class RemovePermissionsAndRoles < ActiveRecord::Migration
  def self.up
    drop_table :permissions
    drop_table :roles_permissions
  end

  def self.down
    create_table :permissions do |t|
      t.string :entity
      t.string :action
      t.timestamps
    end

    create_table :roles_permissions, :id => false do |t|
      t.references :role, :permission
    end  
  end
end

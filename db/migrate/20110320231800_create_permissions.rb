class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.string :entity
      t.string :action

      t.timestamps
    end
  end

  def self.down
    drop_table :permissions
  end
end

class CreateAccessRights < ActiveRecord::Migration
  def self.up
    create_table :access_rights do |t|
      t.string :license_type
      t.timestamps
    end
  end

  def self.down
    drop_table :access_rights
  end
end

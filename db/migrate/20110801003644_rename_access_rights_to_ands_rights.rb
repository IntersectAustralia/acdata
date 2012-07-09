class RenameAccessRightsToAndsRights < ActiveRecord::Migration
  def self.up
    rename_table :access_rights, :ands_rights
  end

  def self.down
    rename_table :ands_rights, :access_rights
  end
end

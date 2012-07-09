class RenameRightsAndAccessRightsInAndsPublishables < ActiveRecord::Migration
  def self.up
    rename_column :ands_publishables, :access_rights_id, :ands_rights_id
    rename_column :ands_publishables, :rights, :access_rights
  end

  def self.down
    rename_column :ands_publishables, :ands_rights_id, :access_rights_id
    rename_column :ands_publishables, :access_rights, :rights
  end
end

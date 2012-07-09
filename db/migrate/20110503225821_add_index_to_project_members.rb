class AddIndexToProjectMembers < ActiveRecord::Migration
  def self.up
    add_index :project_members, :project_id, :name => :project_members_project_id_index
  end

  def self.down
    remove_index :project_members, :project_members_project_id_index
  end
end

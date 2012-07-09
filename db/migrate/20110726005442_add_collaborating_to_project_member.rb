class AddCollaboratingToProjectMember < ActiveRecord::Migration
  def self.up
    add_column :project_members, :collaborating, :boolean, :default => false
    rename_column :project_members, :member_id, :user_id
  end

  def self.down
    rename_column :project_members, :user_id, :member_id
    remove_column :project_members, :collaborating

  end
end

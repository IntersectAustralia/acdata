class DropColumnFolderFromProjects < ActiveRecord::Migration
  def self.up
    remove_column :projects, :folder
  end

  def self.down
    add_column :projects, :string
  end
end

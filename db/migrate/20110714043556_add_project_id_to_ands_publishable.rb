class AddProjectIdToAndsPublishable < ActiveRecord::Migration
  def self.up
    add_column :ands_publishables, :project_id, :integer
  end

  def self.down
    remove_column :ands_publishables, :project_id
  end
end

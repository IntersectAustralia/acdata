class AddProjectIdToExperiment < ActiveRecord::Migration
  def self.up
    add_column :experiments, :project_id, :integer
  end

  def self.down
    remove_column :experiments, :project_id
  end
end

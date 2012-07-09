class CreateProjectExperiments < ActiveRecord::Migration
  def self.up
    create_table :project_experiments, :id => false do |t|
      t.references :project, :null => false
      t.references :experiment, :null => false
    end
  end

  def self.down
    drop_table :project_experiments
  end
end

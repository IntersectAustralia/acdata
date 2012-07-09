class CreateSamples < ActiveRecord::Migration
  def self.up
    create_table :samples do |t|
      t.string :name
      t.string :batchId
      t.string :batchIdDescription
      t.integer :project_id
      t.integer :experiment_id

      t.timestamps
    end
  end

  def self.down
    drop_table :samples
  end
end

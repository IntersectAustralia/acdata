class AddTimestampsToDatasets < ActiveRecord::Migration
  def self.up
    change_table :datasets do |t|
      t.timestamps
    end
  end

  def self.down
    remove_column :datasets, :created_at
    remove_column :datasets, :updated_at
  end
end

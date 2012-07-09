class RemoveGraphFileColumnFromDatasets < ActiveRecord::Migration
  def self.up
    remove_column :datasets, :graph_file
  end

  def self.down
    add_column :datasets, :graph_file, :string
  end
end

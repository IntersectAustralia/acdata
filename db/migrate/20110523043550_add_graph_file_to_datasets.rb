class AddGraphFileToDatasets < ActiveRecord::Migration
  def self.up
    add_column :datasets, :graph_file, :string
  end

  def self.down
    remove_column :datasets, :graph_file
  end
end

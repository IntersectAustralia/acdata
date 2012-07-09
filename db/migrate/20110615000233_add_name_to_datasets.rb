class AddNameToDatasets < ActiveRecord::Migration
  def self.up
    add_column :datasets, :name, :string
  end

  def self.down
    remove_column :datasets, :name
  end
end

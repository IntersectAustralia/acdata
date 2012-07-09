class AddExternalSourceToDatasets < ActiveRecord::Migration
  def self.up
    add_column :datasets, :external_data_source, :string
    add_column :datasets, :external_id, :integer
  end

  def self.down
    remove_column :datasets, :external_id
    remove_column :datasets, :external_data_source
  end
end

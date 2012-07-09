class AddExternalSourceToSamples < ActiveRecord::Migration
  def self.up
    add_column :samples, :external_data_source, :string
    add_column :samples, :external_id, :integer
  end

  def self.down
    remove_column :samples, :external_id
    remove_column :samples, :external_data_source
  end
end

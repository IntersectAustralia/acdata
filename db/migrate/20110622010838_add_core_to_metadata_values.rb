class AddCoreToMetadataValues < ActiveRecord::Migration
  def self.up
    add_column :metadata_values, :core, :boolean
  end

  def self.down
    remove_column :metadata_values, :core
  end
end

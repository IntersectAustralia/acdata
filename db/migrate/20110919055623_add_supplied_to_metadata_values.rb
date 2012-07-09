class AddSuppliedToMetadataValues < ActiveRecord::Migration
  def self.up
    add_column :metadata_values, :supplied, :boolean
  end

  def self.down
    remove_column :metadata_values, :supplied
  end
end

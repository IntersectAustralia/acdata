class AddMetadataListToInstruments < ActiveRecord::Migration
  def self.up
    add_column :instruments, :metadata_list, :string
  end

  def self.down
    remove_column :instruments, :metadata_list
  end
end

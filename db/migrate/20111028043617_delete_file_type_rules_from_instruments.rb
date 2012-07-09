class DeleteFileTypeRulesFromInstruments < ActiveRecord::Migration
  def self.up
    remove_column :instruments, :visualisation_list
    remove_column :instruments, :metadata_list
    remove_column :instruments, :unique_list
    remove_column :instruments, :exclusive_list
    remove_column :instruments, :indelible_list
  end

  def self.down
    add_column :instruments, :visualisation_list, :string
    add_column :instruments, :metadata_list, :string
    add_column :instruments, :unique_list, :string
    add_column :instruments, :exclusive_list, :string
    add_column :instruments, :indelible_list, :string
  end
end

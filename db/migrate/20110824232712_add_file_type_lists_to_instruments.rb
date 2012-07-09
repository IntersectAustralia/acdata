class AddFileTypeListsToInstruments < ActiveRecord::Migration
  def self.up
    add_column :instruments, :exclusive_list, :string
    add_column :instruments, :unique_list, :string
    add_column :instruments, :immutable_list, :string
  end

  def self.down
    remove_column :instruments, :exclusive_list
    remove_column :instruments, :unique_list
    remove_column :instruments, :immutable_list
  end
end

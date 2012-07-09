class RenameImmutableListToIndelibleList < ActiveRecord::Migration
  def self.up
    rename_column :instruments, :immutable_list, :indelible_list
  end

  def self.down
    rename_column :instruments, :indelible_list, :immutable_list
  end
end

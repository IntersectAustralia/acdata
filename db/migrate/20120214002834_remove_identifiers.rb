class RemoveIdentifiers < ActiveRecord::Migration
  def self.up
    remove_column :instruments, :identifier
    remove_column :ands_publishables, :handle

  end

  def self.down
    add_column :instruments, :identifier, :string
    add_column :ands_publishables, :handle, :string
  end
end
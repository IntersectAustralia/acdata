class AddAndsHandleIdtoAssignables < ActiveRecord::Migration
  def self.up
    add_column :ands_publishables, :ands_handle_id, :integer
    add_column :instruments, :ands_handle_id, :integer
  end

  def self.down
    remove_column :ands_publishables, :ands_handle_id
    remove_column :instruments, :ands_handle_id
  end
end

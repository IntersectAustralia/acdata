class RemoveAndsHandleIdFromAssignables < ActiveRecord::Migration
  def self.up
    remove_column :ands_publishables, :ands_handle_id
    remove_column :instruments, :ands_handle_id
  end

  def self.down
    add_column :ands_publishables, :ands_handle_id, :integer
    add_column :instruments, :ands_handle_id, :integer
  end
end

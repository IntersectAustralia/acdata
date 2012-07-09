class AddHandleToAndsPublishable < ActiveRecord::Migration
  def self.up
    add_column :ands_publishables, :handle, :string
  end

  def self.down
    remove_column :ands_publishables, :handle
  end
end

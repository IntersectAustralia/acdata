class AddStatusToAndsPublishable < ActiveRecord::Migration
  def self.up
    add_column :ands_publishables, :status, :string, :default => 'U'

  end

  def self.down
    remove_column :ands_publishables, :status

  end
end

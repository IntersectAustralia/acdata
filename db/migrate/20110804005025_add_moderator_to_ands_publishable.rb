class AddModeratorToAndsPublishable < ActiveRecord::Migration
  def self.up
    add_column :ands_publishables, :moderator_id, :integer
  end

  def self.down
    remove_column :ands_publishables, :moderator_id
  end
end

class AddPublishedFlagToAndsPublishable < ActiveRecord::Migration
  def self.up
    add_column :ands_publishables, :published, :boolean, :default => true

  end

  def self.down
    remove_column :ands_publishables, :published
  end
end

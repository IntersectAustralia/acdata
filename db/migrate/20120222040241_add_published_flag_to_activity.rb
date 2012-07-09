class AddPublishedFlagToActivity < ActiveRecord::Migration
  def self.up
    add_column :activities, :published, :boolean, :default => false
  end

  def self.down
    remove_column :activities, :published
  end
end

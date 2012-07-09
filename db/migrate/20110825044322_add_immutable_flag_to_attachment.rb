class AddImmutableFlagToAttachment < ActiveRecord::Migration
  def self.up
    add_column :attachments, :immutable, :boolean, :default => false
  end

  def self.down
    remove_column :attachments, :immutable
  end
end

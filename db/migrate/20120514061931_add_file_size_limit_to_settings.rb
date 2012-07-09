class AddFileSizeLimitToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :file_size_limit, :integer, :default => 64
    Settings.instance.update_attribute(:file_size_limit, 64)
  end

  def self.down
    remove_column :settings, :file_size_limit
  end
end

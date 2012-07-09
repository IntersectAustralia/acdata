class AddFileFilterToFileTypes < ActiveRecord::Migration
  def self.up
    add_column :file_types, :filter, :string
  end

  def self.down
    remove_column :file_types, :filter
  end
end

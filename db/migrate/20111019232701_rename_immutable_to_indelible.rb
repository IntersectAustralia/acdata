class RenameImmutableToIndelible < ActiveRecord::Migration
  def self.up
    rename_column :attachments, :immutable, :indelible
  end

  def self.down
    rename_column :attachments, :indelible, :immutable
  end
end

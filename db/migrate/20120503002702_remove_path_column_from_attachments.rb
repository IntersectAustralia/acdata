class RemovePathColumnFromAttachments < ActiveRecord::Migration
  def self.up
    remove_column :attachments, :path
  end

  def self.down
    add_column :attachments, :path, :string, {:limit => 2048}
  end
end

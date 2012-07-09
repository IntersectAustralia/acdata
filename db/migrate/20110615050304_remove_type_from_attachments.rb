class RemoveTypeFromAttachments < ActiveRecord::Migration
  def self.up
    remove_column :attachments, :type
  end

  def self.down
    add_column :attachments, :type, :string
  end
end

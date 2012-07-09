class AddAttachmentIdToMetadataValue < ActiveRecord::Migration
  def self.up
    add_column :metadata_values, :attachment_id, :integer

  end

  def self.down
    remove_column :metadata_values, :attachment_id

  end
end

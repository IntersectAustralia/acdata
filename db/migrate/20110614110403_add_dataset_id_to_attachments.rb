class AddDatasetIdToAttachments < ActiveRecord::Migration
  def self.up
    add_column :attachments, :dataset_id, :integer
  end

  def self.down
    remove_column :attachments, :dataset_id
  end
end

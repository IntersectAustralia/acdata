class AddPreviewMimeToAttachments < ActiveRecord::Migration
  def self.up
    change_table :attachments do |t|
      t.string :preview_mime_type
    end
  end

  def self.down
    remove_column :attachments, :preview_mime_type
  end
end

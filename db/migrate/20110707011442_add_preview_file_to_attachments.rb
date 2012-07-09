class AddPreviewFileToAttachments < ActiveRecord::Migration
  def self.up
    change_table :attachments do |t|
      t.string :preview_file
    end
  end

  def self.down
    remove_column :attachments, :preview_file
  end
end

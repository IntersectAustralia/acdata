class UpdatePreviewAttachmentPath < ActiveRecord::Migration
  def self.up
    Attachment.where("preview_file is not NULL").each do |attachment|
      old_path = attachment.preview_file
      new_path = File.basename(old_path)
      attachment.preview_file = new_path
      attachment.save!
    end
  end

  def self.down
  end
end

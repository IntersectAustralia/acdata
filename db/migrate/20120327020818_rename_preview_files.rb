class RenamePreviewFiles < ActiveRecord::Migration
  def self.up
    Attachment.where("preview_file is not NULL").each do |att|
      old_preview_file = att.preview_file
      path, filename = File.split(old_preview_file)
      next if filename =~ /^\./
      
      new_preview_file = File.join(path, ".#{filename}")
      begin
        puts "Renaming #{old_preview_file} -> #{new_preview_file}"
        att.preview_file = new_preview_file
        att.save!
        FileUtils.mv(old_preview_file, new_preview_file)
      rescue
        FileUtils.mv(new_preview_file, old_preview_file) if File.exists?(new_preview_file)
      end
    end
  end

  def self.down
  end
end

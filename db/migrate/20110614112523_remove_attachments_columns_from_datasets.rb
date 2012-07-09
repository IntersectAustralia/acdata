class RemoveAttachmentsColumnsFromDatasets < ActiveRecord::Migration
  def self.up
    remove_column :datasets, :attachment_file_name
    remove_column :datasets, :attachment_content_type
  end

  def self.down
    add_column :datasets, :attachment_file_name, :string
    add_column :datasets, :attachment_content_type, :string
  end
end

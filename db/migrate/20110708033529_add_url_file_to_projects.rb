class AddUrlFileToProjects < ActiveRecord::Migration
  def self.up
    change_table :projects do |t|
      t.string :url, {:limit => 2048}
      t.string :document_file_name, {:limit => 2048}
      t.string :document_content_type
      t.integer :document_file_size
      t.datetime :document_updated_at
    end
  end

  def self.down
    change_table :projects do |t|
      t.remove :url
      t.remove :document_file_name
      t.remove :document_content_type
      t.remove :document_file_size
      t.remove :document_updated_at
    end
  end
end

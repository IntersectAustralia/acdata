class CreateDatasets < ActiveRecord::Migration
  def self.up
    create_table :datasets do |t|
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :sample_id
    end
  end

  def self.down
    drop_table :datasets
  end
end

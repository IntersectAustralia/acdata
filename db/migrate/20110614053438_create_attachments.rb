class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.string :filename
      t.string :path
      t.string :type
      t.string :format
      t.timestamps
    end
  end

  def self.down
    drop_table :attachments
  end
end

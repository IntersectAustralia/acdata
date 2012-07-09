class AddInstrumentFileTypeToAttachment < ActiveRecord::Migration
  def self.up
    add_column :attachments, :instrument_file_type_id, :integer
  end

  def self.down
    drop_column :attachments, :instrument_file_type_id
  end
end

class RenameFileTypeToInstrumentFileType < ActiveRecord::Migration
  def self.up
    rename_table :file_types, :instrument_file_types
  end

  def self.down
    rename_table :instrument_file_types, :file_types
  end
end

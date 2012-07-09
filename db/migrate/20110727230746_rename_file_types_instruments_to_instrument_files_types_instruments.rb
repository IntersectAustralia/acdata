class RenameFileTypesInstrumentsToInstrumentFilesTypesInstruments < ActiveRecord::Migration
  def self.up
    rename_table :file_types_instruments, :instrument_file_types_instruments
    rename_column :instrument_file_types_instruments, :file_type_id, :instrument_file_type_id
  end

  def self.down
    rename_table :instrument_file_types_instruments, :file_types_instruments
    rename_column :file_types_instruments, :instrument_file_type_id, :file_type_id
  end
end

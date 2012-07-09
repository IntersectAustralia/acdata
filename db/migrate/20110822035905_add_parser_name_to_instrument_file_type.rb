class AddParserNameToInstrumentFileType < ActiveRecord::Migration
  def self.up
    add_column :instrument_file_types, :parser_name, :string
  end

  def self.down
    remove_column :instrument_file_types, :parser_name
  end
end

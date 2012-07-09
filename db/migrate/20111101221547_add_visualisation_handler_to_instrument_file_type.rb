class AddVisualisationHandlerToInstrumentFileType < ActiveRecord::Migration
  def self.up
    add_column :instrument_file_types, :visualisation_handler, :string
  end

  def self.down
    remove_column :instrument_file_types, :visualisation_handler
  end
end

class AddInstrumentIdToDatasets < ActiveRecord::Migration
  def self.up
    add_column :datasets, :instrument_id, :integer
  end

  def self.down
    remove_column :datasets, :instrument_id
  end
end

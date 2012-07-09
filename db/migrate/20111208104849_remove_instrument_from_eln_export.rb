class RemoveInstrumentFromElnExport < ActiveRecord::Migration
  def self.up
    remove_column :eln_exports, :instrument
  end

  def self.down
    add_column :eln_exports, :instrument, :string
  end
end

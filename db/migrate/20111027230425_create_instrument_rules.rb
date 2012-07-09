class CreateInstrumentRules < ActiveRecord::Migration
  def self.up
    create_table :instrument_rules do |t|
      t.references :instrument
      t.string :unique_list
      t.string :exclusive_list
      t.string :indelible_list
      t.string :metadata_list
      t.string :visualisation_list

      t.timestamps
    end
  end

  def self.down
    drop_table :instrument_rules
  end
end

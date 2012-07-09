class CreateInstruments < ActiveRecord::Migration
  def self.up
    create_table :instruments do |t|
      t.string :name
      t.string :model
      t.string :identifier
      t.string :location

      t.timestamps
    end
  end

  def self.down
    drop_table :instruments
  end
end

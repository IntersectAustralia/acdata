class CreateInstrumentsFileTypes < ActiveRecord::Migration
  def self.up
    create_table 'file_types_instruments', :id => false do |t|
      t.column :file_type_id, :integer
      t.column :instrument_id, :integer
    end
  end

  def self.down
    drop_table 'file_types_instruments'
  end
end

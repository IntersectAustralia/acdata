class CreateElnExportMetadata < ActiveRecord::Migration
  def self.up
    create_table :eln_export_metadata do |t|
      t.references :eln_export
      t.string :key
      t.string :value
      t.timestamps
    end
  end

  def self.down
    drop_table :eln_export_metadata
  end
end

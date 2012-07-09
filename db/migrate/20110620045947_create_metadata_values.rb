class CreateMetadataValues < ActiveRecord::Migration
  def self.up
    create_table :metadata_values do |t|
      t.string :key
      t.string :value
      t.integer :dataset_id

      t.timestamps
    end
  end

  def self.down
    drop_table :metadata_values
  end
end

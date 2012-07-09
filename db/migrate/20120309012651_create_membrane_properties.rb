class CreateMembraneProperties < ActiveRecord::Migration
  def self.up
    create_table :membrane_properties do |t|
      t.string :name
      t.string :property_type
      t.text :description
      t.string :property_units
      t.string :qualifier1
      t.string :qualifier2
      t.string :qualifier3
      t.text :measurement_techniques

      t.timestamps
    end
  end

  def self.down
    drop_table :membrane_properties
  end
end

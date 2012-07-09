class CreatePropertyDetails < ActiveRecord::Migration
  def self.up
    create_table :property_details do |t|
      t.integer :memre_export_id
      t.string :property_type
      t.string :measurement_technique
      t.string :type_of_property
      t.string :units
      t.string :description
      t.string :qualifier_1
      t.string :qualifier_2
      t.string :qualifier_3
      t.string :info_type
      t.string :identifier
      t.string :title
      t.timestamps
    end
  end

  def self.down
    drop_table :property_details
  end
end

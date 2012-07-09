class RemoveFieldsFromMemreExport < ActiveRecord::Migration
  def self.up
    remove_column :memre_exports, :property_type
    remove_column :memre_exports, :measurement_technique
    remove_column :memre_exports, :type_of_property
    remove_column :memre_exports, :property_units
    remove_column :memre_exports, :description
    remove_column :memre_exports, :qualifier1
    remove_column :memre_exports, :qualifier2
    remove_column :memre_exports, :qualifier3
  end

  def self.down
    add_column :memre_exports, :property_type, :string
    add_column :memre_exports, :measurement_technique, :string
    add_column :memre_exports, :type_of_property, :string
    add_column :memre_exports, :property_units, :string
    add_column :memre_exports, :description, :string
    add_column :memre_exports, :qualifier1, :string
    add_column :memre_exports, :qualifier2, :string
    add_column :memre_exports, :qualifier3, :string
  end
end

class RenameColumnsInMemreExports < ActiveRecord::Migration
  def self.up
    rename_column :memre_exports, :membrane_property_type, :property_type
    rename_column :memre_exports, :membrane_measurement_technique, :measurement_technique
    rename_column :memre_exports, :membrane_type, :type_of_property
    rename_column :memre_exports, :membrane_units, :property_units
    rename_column :memre_exports, :membrane_description, :description
    rename_column :memre_exports, :membrane_qualifier1, :qualifier1
    rename_column :memre_exports, :membrane_qualifier2, :qualifier2
    rename_column :memre_exports, :membrane_qualifier3, :qualifier3
  end

  def self.down
    rename_column :memre_exports, :property_type, :membrane_property_type
    rename_column :memre_exports, :measurement_technique, :membrane_measurement_technique
    rename_column :memre_exports, :type_of_property, :membrane_type
    rename_column :memre_exports, :property_units, :membrane_units
    rename_column :memre_exports, :description, :membrane_description
    rename_column :memre_exports, :qualifier1, :membrane_qualifier1
    rename_column :memre_exports, :qualifier2, :membrane_qualifier2
    rename_column :memre_exports, :qualifier3, :membrane_qualifier3
  end
end

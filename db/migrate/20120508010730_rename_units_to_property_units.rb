class RenameUnitsToPropertyUnits < ActiveRecord::Migration
  def self.up
    rename_column :property_details, :units, :property_units
  end

  def self.down
    rename_column :property_details, :property_units, :units
  end
end

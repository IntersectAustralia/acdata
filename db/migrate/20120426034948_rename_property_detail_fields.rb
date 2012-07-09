class RenamePropertyDetailFields < ActiveRecord::Migration
  def self.up
    rename_column :property_details, :property_type, :name
    rename_column :property_details, :title, :notes

  end

  def self.down

    rename_column :property_details, :notes, :title
    rename_column :property_details, :name, :property_type
  end
end

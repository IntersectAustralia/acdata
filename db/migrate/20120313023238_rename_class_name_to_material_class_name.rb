class RenameClassNameToMaterialClassName < ActiveRecord::Migration
  def self.up
    rename_column :memre_exports, :class_name, :material_class_name
  end

  def self.down
    rename_column :memre_exports, :material_class_name, :class_name
  end
end

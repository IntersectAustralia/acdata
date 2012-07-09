class RenameBatchIdDescriptionToDescription < ActiveRecord::Migration
  def self.up
    rename_column :samples, :batch_id_description, :description
  end

  def self.down
    rename_column :samples, :description, :batch_id_description
  end
end

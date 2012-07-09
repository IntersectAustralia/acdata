class RenameBatchiddescription < ActiveRecord::Migration
  def self.up
     rename_column :samples, :batchIdDescription, :batch_id_description
  end

  def self.down
    rename_column :samples, :batch_id_description, :batchIdDescription
  end
end

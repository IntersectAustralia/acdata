class ChangeDatasetExternalIdType < ActiveRecord::Migration

  def self.up
    rename_column :datasets, :external_id, :old_external_id
    add_column :datasets, :external_id, :integer
    Dataset.reset_column_information
    Dataset.all.each {|e| e.update_attribute(:external_id, e.old_external_id.to_i) if e.old_external_id}
    remove_column :datasets, :old_external_id
  end

  def self.down
  	change_column :datasets,:external_id,:string
  end
end

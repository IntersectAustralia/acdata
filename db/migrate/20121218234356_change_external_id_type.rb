class ChangeExternalIdType < ActiveRecord::Migration
  def self.up
  	change_column :datasets,:external_id,:string
  	change_column :samples,:external_id,:string
  end

  def self.down
  	change_column :datasets,:external_id,:integer
  	change_column :samples,:external_id,:integer
  end
end

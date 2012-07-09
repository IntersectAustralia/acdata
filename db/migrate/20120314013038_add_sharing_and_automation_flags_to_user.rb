class AddSharingAndAutomationFlagsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :allow_memre_export, :boolean
    add_column :users, :allow_nmr_import, :boolean
    add_column :users, :allow_slide_scanning_requests, :boolean
  end

  def self.down
    remove_column :users, :allow_slide_scanning_requests
    remove_column :users, :allow_nmr_import
    remove_column :users, :allow_memre_export
  end
end

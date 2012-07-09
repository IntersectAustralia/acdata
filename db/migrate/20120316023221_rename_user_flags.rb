class RenameUserFlags < ActiveRecord::Migration
  def self.up
    rename_column :users, :allow_eln_export, :eln_enabled
    rename_column :users, :allow_memre_export, :memre_enabled
    rename_column :users, :allow_nmr_import, :nmr_enabled
    rename_column :users, :allow_slide_scanning_requests, :slide_request_enabled
  end

  def self.down
    rename_column :users, :eln_enabled, :allow_eln_export
    rename_column :users, :memre_enabled, :allow_memre_export
    rename_column :users, :nmr_enabled, :allow_nmr_import
    rename_column :users, :slide_request_enabled, :allow_slide_scanning_requests
  end
end

class AddSlideScanningEmailToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :slide_scanning_email, :string

    Settings.instance.update_attribute(:slide_scanning_email, APP_CONFIG['slide_scanning_request_admin_email'])
  end

  def self.down
    remove_column :settings, :slide_scanning_email

  end
end

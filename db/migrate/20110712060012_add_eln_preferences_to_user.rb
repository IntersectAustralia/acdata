class AddElnPreferencesToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :allow_eln_export, :boolean
  end

  def self.down
    remove_column :users, :allow_eln_export
  end
end

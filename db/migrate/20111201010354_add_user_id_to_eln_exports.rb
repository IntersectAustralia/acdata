class AddUserIdToElnExports < ActiveRecord::Migration
  def self.up
    add_column :eln_exports, :user_id, :integer
  end

  def self.down
    remove_column :eln_exports, :user_id
  end
end

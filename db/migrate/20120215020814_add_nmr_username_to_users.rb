class AddNmrUsernameToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :nmr_username, :string
  end

  def self.down
    remove_column :users, :nmr_username
  end
end

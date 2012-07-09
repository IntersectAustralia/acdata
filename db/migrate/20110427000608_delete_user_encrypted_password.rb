class DeleteUserEncryptedPassword < ActiveRecord::Migration
  def self.up
    remove_column :users, :encrypted_password
    remove_column :users, :reset_password_token
  end

  def self.down
    add_column :users, :encrypted_password, :string, { :limit => 128, :default => "", :null => false }
    add_column :users, :reset_password_token, :string
  end
end

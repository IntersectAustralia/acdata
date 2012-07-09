class AddFieldsToInstruments < ActiveRecord::Migration
  def self.up
    add_column :instruments, :description, :text
    add_column :instruments, :email, :string
    add_column :instruments, :voice, :string
    add_column :instruments, :address, :text
    add_column :instruments, :managed_by, :string
    remove_column :instruments, :location
  end

  def self.down
    remove_column :instruments, :description, :text
    remove_column :instruments, :email, :string
    remove_column :instruments, :voice, :string
    remove_column :instruments, :removeress, :text
    remove_column :instruments, :managed_by, :string
    add_column :instruments, :location, :string
  end
end

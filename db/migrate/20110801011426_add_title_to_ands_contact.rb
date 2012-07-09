class AddTitleToAndsContact < ActiveRecord::Migration
  def self.up
    add_column :ands_contacts, :title, :string
  end

  def self.down
    remove_column :ands_contact, :title
  end
end

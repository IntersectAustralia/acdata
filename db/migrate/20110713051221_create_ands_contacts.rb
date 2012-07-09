class CreateAndsContacts < ActiveRecord::Migration
  def self.up
    create_table :ands_contacts do |t|
      t.string :family_name
      t.string :given_name
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :ands_contacts
  end
end

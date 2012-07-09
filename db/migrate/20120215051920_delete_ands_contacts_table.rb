class DeleteAndsContactsTable < ActiveRecord::Migration
  def self.up
    remove_column :ands_publishables, :ands_contact_id
    drop_table :ands_contacts

  end

  def self.down
    create_table :ands_contacts do |t|
      t.string :family_name
      t.string :given_name
      t.string :email
      t.string :title
      t.timestamps
    end

    add_column :ands_publishables, :ands_contact_id, :integer
  end
end

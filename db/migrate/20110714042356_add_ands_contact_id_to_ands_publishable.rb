class AddAndsContactIdToAndsPublishable < ActiveRecord::Migration
  def self.up
    add_column :ands_publishables, :ands_contact_id, :integer
  end

  def self.down
    remove_column :ands_publishables, :ands_contact_id
  end
end

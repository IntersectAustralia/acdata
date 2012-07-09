class CreateAndsRelatedObjects < ActiveRecord::Migration
  def self.up
    create_table :ands_related_objects do |t|
      t.string :handle
      #unsw party, service, activity
      t.string :description
      t.string :relation_type
      t.references :ands_publishable
      t.timestamps
    end
  end

  def self.down
    drop_table :ands_related_objects
  end
end

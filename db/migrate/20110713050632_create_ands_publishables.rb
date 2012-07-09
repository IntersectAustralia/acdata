class CreateAndsPublishables < ActiveRecord::Migration
  def self.up
    create_table :ands_publishables do |t|
      t.string :collection_name
      t.string :collection_description
      t.string :research_group

      t.timestamps
    end
  end

  def self.down
    drop_table :ands_publishables
  end
end

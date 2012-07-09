class CreateAndsRelatedInfos < ActiveRecord::Migration
  def self.up
    create_table :ands_related_infos do |t|
      t.references :ands_publishable
      t.string :info_type
      t.string :identifier
      t.string :title
      t.timestamps
    end
  end

  def self.down
    drop_table :ands_related_infos
  end
end

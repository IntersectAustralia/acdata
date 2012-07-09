class AddAndsPublishableJoinTables < ActiveRecord::Migration
  def self.up

    create_table :ands_publishables_seo_codes, :id => false do |t|
      t.references :ands_publishable
      t.references :seo_code
    end

    create_table :ands_publishables_for_codes, :id => false do |t|
      t.references :ands_publishable
      t.references :for_code
    end

  end

  def self.down

    drop_table :ands_publishables_for_codes
    drop_table :ands_publishables_seo_codes
  end
end

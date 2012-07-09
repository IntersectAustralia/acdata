class CreateRdaGrants < ActiveRecord::Migration
  def self.up
    create_table :rda_grants do |t|
      t.string :group
      t.string :key
      t.string :primary_name
      t.string :alternative_name
      t.text :description
      t.string :grant_id
      t.timestamps
    end
  end

  def self.down
    drop_table :rda_grants
  end
end

class CreateAndsParties < ActiveRecord::Migration
  def self.up
    create_table :ands_parties do |t|
      t.string :given_name
      t.string :family_name
      t.string :title
      t.string :email
      t.string :key

      t.timestamps
    end
  end

  def self.down
    drop_table :ands_parties
  end
end

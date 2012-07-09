class AddIndexToAndsParties < ActiveRecord::Migration
  def self.up
    add_index :ands_parties, :key
  end

  def self.down
    remove_index :ands_parties, :key
  end
end

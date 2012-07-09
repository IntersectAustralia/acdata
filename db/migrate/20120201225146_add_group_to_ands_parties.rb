class AddGroupToAndsParties < ActiveRecord::Migration
  def self.up
    add_column :ands_parties, :group, :string
  end

  def self.down
    remove_column :ands_parties, :group
  end
end

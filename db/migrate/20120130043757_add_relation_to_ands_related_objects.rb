class AddRelationToAndsRelatedObjects < ActiveRecord::Migration
  def self.up
    add_column :ands_related_objects, :relation, :string
    add_column :ands_related_objects, :name, :string
  end

  def self.down
    remove_column :ands_related_objects, :relation
    remove_column :ands_related_objects, :name

  end
end

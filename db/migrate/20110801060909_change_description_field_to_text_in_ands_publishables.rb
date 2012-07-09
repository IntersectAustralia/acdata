class ChangeDescriptionFieldToTextInAndsPublishables < ActiveRecord::Migration
  def self.up
    change_column :ands_publishables, :collection_description, :text
  end

  def self.down
    change_column :ands_publishables, :collection_description, :string
  end
end

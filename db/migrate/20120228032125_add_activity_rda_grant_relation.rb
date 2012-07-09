class AddActivityRdaGrantRelation < ActiveRecord::Migration
  def self.up
    add_column :activities, :rda_grant_id, :integer
    remove_column :activities, :rda_handle
  end

  def self.down
    add_column :activities, :rda_handle, :string
    remove_column :activities, :rda_grant_id
  end
end

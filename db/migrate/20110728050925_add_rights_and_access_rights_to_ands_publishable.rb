class AddRightsAndAccessRightsToAndsPublishable < ActiveRecord::Migration
  def self.up
    add_column :ands_publishables, :rights, :string
    add_column :ands_publishables, :access_rights_id, :integer
  end

  def self.down
    remove_column :ands_publishables, :rights
    remove_column :ands_publishables, :access_rights_id
  end
end
                  '

'
class CreateProjectMembers < ActiveRecord::Migration
  def self.up
    create_table 'project_members', :id => false do |t|
      t.column :project_id, :integer
      t.column :member_id, :integer
    end
  end

  def self.down
    drop_table 'project_members'
  end
end

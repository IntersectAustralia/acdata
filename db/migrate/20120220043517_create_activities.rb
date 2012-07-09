class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.boolean :from_rda
      t.string :rda_handle
      t.string :project_name
      t.string :initial_year
      t.string :duration
      t.string :total_grant_budget
      t.string :funding_sponsor
      t.string :funding_scheme
      t.string :project_type
      t.integer :project_id
      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end

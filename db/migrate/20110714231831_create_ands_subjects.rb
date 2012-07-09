class CreateAndsSubjects < ActiveRecord::Migration
  def self.up
    create_table :ands_subjects do |t|
      t.string :keyword
      t.integer :ands_publishable_id
      t.timestamps
    end
  end

  def self.down
    drop_table :ands_subjects
  end
end

class AddAndsPublishableSubjectsJoinTable < ActiveRecord::Migration
  def self.up
    create_table :ands_publishables_ands_subjects, :id => false do |t|
      t.references :ands_publishable
      t.references :ands_subject
    end

    remove_column :ands_subjects, :ands_publishable_id
  end

  def self.down
    drop_table :ands_publishables_ands_subjects
    add_column :ands_subjects, :ands_publishable_id, :integer

  end
end

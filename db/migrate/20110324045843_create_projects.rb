class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.string :folder
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end

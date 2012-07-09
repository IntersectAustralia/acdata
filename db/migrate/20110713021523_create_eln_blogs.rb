class CreateElnBlogs < ActiveRecord::Migration
  def self.up
    create_table :eln_blogs do |t|
      t.string :name
      t.references :user, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :eln_blogs
  end
end

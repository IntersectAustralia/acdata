class AddBlogNameToElnExports < ActiveRecord::Migration
  def self.up
    add_column :eln_exports, :blog_name, :string
  end

  def self.down
    remove_column :eln_exports, :blog_name
  end
end

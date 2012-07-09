class AddPostUrlToElnExports < ActiveRecord::Migration
  def self.up
    add_column :eln_exports, :post_url, :string
  end

  def self.down
    remove_column :eln_exports, :post_url
  end
end

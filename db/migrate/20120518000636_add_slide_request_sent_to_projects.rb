class AddSlideRequestSentToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :slide_request_sent, :boolean, :default => false
  end

  def self.down
    remove_column :projects, :slide_request_sent
  end
end

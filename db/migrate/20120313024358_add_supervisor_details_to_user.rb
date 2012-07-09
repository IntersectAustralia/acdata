class AddSupervisorDetailsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :supervisor_name, :string
    add_column :users, :supervisor_email, :string
    add_column :users, :is_supervisor, :boolean, :default => false

  end

  def self.down
    remove_column :users, :is_supervisor
    remove_column :users, :supervisor_email
    remove_column :users, :supervisor_name

  end
end

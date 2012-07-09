class RenameIsSupervisorToIsStudent < ActiveRecord::Migration
  def self.up
    rename_column :users, :is_supervisor, :is_student
    change_column_default :users, :is_student, false

    User.find_each do |user|
      user.update_attribute(:is_student, !user.is_student)
    end

  end

  def self.down
    rename_column :users, :is_student, :is_supervisor
    change_column_default :users, :is_supervisor, true

    User.find_each do |user|
      user.update_attribute(:is_supervisor, !user.is_supervisor)
    end
  end
end

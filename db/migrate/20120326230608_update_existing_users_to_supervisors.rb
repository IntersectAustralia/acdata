class UpdateExistingUsersToSupervisors < ActiveRecord::Migration
  def self.up
    User.find_each do |user|
      if !user.is_supervisor? and user.supervisor_name.blank?
        user.update_attribute(:is_supervisor, true)
      end
    end
  end

  def self.down

  end
end

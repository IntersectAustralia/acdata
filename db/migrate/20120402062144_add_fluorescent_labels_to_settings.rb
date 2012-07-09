class AddFluorescentLabelsToSettings < ActiveRecord::Migration
  def self.up
    add_column :fluorescent_labels, :settings_id, :integer

    FluorescentLabel.find_each do |label|
      label.update_attribute(:settings, Settings.instance)
    end
  end

  def self.down
    remove_column :fluorescent_labels, :settings_id

  end
end

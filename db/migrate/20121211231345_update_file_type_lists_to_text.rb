class UpdateFileTypeListsToText < ActiveRecord::Migration
  def self.up
    change_column :instrument_rules, :indelible_list, :text
    change_column :instrument_rules, :metadata_list, :text
    change_column :instrument_rules, :visualisation_list, :text
    change_column :instrument_rules, :unique_list, :text
    change_column :instrument_rules, :exclusive_list, :text
  end
  def self.down
  end
end

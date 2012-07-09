class AddAndsPublishableFieldsForm1 < ActiveRecord::Migration
  def self.up
    add_column :ands_publishables, :address, :text
    add_column :ands_publishables, :has_temporal_coverage, :boolean, :default => false
    add_column :ands_publishables, :coverage_start_date, :date
    add_column :ands_publishables, :coverage_end_date, :date


  end

  def self.down
    remove_column :ands_publishables, :address
    remove_column :ands_publishables, :has_temporal_coverage
    remove_column :ands_publishables, :coverage_start_date
    remove_column :ands_publishables, :coverage_end_date
  end

end

class ChangeDescriptionsToText < ActiveRecord::Migration
  def self.up
    change_column :experiments, :description, :text
        change_column :samples, :batchIdDescription, :text
  end

  def self.down
    change_column :experiments, :description, :string
            change_column :samples, :batchIdDescription, :string
  end
end

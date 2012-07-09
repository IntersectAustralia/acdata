class RemoveSampleBatchId < ActiveRecord::Migration
  def self.up
    remove_column :samples, :batchId
  end

  def self.down
    add_column :samples, :batchId, :string
  end
end

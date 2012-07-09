class AddAvailableFieldToInstrument < ActiveRecord::Migration
  def self.up
    add_column :instruments, :is_available, :boolean
  end

  def self.down
    remove_column :instruments, :is_available
  end
end

class AddClassAndRemoveModelFromInstrument < ActiveRecord::Migration
  def self.up
    add_column :instruments, :instrument_class, :string
    remove_column :instruments, :model
  end

  def self.down
    remove_column :instruments, :instrument_class
    add_column :instruments, :model, :string
  end
end

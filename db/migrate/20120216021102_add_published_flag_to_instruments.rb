class AddPublishedFlagToInstruments < ActiveRecord::Migration
  def self.up
    add_column :instruments, :published, :boolean, :default => false
    Instrument.find_each do |instrument|
      instrument.update_attribute(:published, false)
    end
  end

  def self.down
    remove_column :instruments, :published
  end
end

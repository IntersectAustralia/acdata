class AddVisualisationListToInstruments < ActiveRecord::Migration
  def self.up
    add_column :instruments, :visualisation_list, :string
  end

  def self.down
    remove_column :instruments, :visualisation_list
  end
end

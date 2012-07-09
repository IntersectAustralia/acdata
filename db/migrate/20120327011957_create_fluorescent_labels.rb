class CreateFluorescentLabels < ActiveRecord::Migration
  def self.up
    create_table :fluorescent_labels do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :fluorescent_labels
  end
end

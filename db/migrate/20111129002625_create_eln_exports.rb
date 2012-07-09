class CreateElnExports < ActiveRecord::Migration
  def self.up
    create_table :eln_exports do |t|
      t.references :dataset
      t.string :title
      t.string :section
      t.string :instrument
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :eln_exports
  end
end

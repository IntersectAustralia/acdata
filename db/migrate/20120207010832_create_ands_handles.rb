class CreateAndsHandles < ActiveRecord::Migration
  def self.up
    create_table :ands_handles do |t|
      t.string :key
      t.integer :assignable_id
      t.string :assignable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :ands_handles
  end
end

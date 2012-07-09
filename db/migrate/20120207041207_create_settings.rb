class CreateSettings < ActiveRecord::Migration
  def self.up
    drop_table :settings
    create_table :settings do |t|
      t.string :start_handle_range
      t.string :end_handle_range

    end
  end

  def self.down
    drop_table :settings
    create_table :settings, :force => true do |t|
      t.string  :var,         :null => false
      t.text    :value
      t.integer :target_id
      t.string  :target_type, :limit => 30
      t.timestamps
    end

    add_index :settings, [ :target_type, :target_id, :var ], :unique => true
  end
end

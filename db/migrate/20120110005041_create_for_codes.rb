class CreateForCodes < ActiveRecord::Migration
  def self.up
    create_table :for_codes do |t|
      t.string :code
      t.string :name

      t.timestamps
    end

  end

  def self.down
    drop_table :for_codes
  end
end

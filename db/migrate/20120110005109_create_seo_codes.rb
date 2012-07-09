class CreateSeoCodes < ActiveRecord::Migration
  def self.up
    create_table :seo_codes do |t|
      t.string :code
      t.string :name

      t.timestamps
    end

  end

  def self.down
    drop_table :seo_codes
  end
end

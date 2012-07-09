class AddActivityForCodesTable < ActiveRecord::Migration
  def self.up
    create_table :activities_for_codes, :id => false do |t|
      t.references :activity
      t.references :for_code
    end

  end

  def self.down
    drop_table :activities_for_codes
  end
end

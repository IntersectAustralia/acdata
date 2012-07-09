class IncreaseLengthOfFilePaths < ActiveRecord::Migration
  def self.up
    change_table :attachments do |t|
      t.change :preview_file, :string, {:limit => 2048}
      t.change :filename, :string, {:limit => 2048}
    end
  end

  def self.down
    change_table :attachments do |t|
      t.change :preview_file, :string, {:limit => 255}
      t.change :filename, :string, {:limit => 255}
    end
  end
end

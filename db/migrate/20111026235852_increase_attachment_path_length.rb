class IncreaseAttachmentPathLength < ActiveRecord::Migration
  def self.up
    change_table :attachments do |t|
      t.change :path, :string, {:limit => 2048}
    end
  end

  def self.down
    change_table :attachments do |t|
      t.change :path, :string, {:limit => 255}
    end
  end
end

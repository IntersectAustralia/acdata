class AddUploadPromptToInstruments < ActiveRecord::Migration
  def self.up
    add_column :instruments, :upload_prompt, :string
  end

  def self.down
    remove_column :instruments, :upload_prompt
  end
end

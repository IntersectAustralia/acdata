class CreateSlideGuidelines < ActiveRecord::Migration
  def self.up
    create_table :slide_guidelines do |t|
      t.text :description
      t.integer :settings_id
      t.timestamps
    end

    config_file = File.expand_path("#{Rails.root}/config/slide_guidelines.yml", __FILE__)
    config = YAML::load_file(config_file)
    file_set = ENV["RAILS_ENV"] || "development"
    config[file_set]['slide_guidelines'].each do |description|
      SlideGuideline.create!(:description => description, :settings => Settings.instance)
    end
  end


  def self.down
    drop_table :slide_guidelines
  end
end

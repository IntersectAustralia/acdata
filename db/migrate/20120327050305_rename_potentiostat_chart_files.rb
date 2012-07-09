class RenamePotentiostatChartFiles < ActiveRecord::Migration
  def self.up
    instrument_ids = InstrumentFileType.select('id').where(:visualisation_handler => 'PotentiostatVisualisation')
    Attachment.where(:instrument_file_type_id => instrument_ids).each do |att|
      puts "Examining attachment: #{att.filename}"
      dataset = att.dataset
      path = dataset.dataset_path
      old_filename = File.join(path, 'potentiostat-chart.png')
      puts "Looking for #{old_filename}"
      if File.exists?(old_filename)
        new_filename = PotentiostatVisualisation.display_file(att)
        #new_filename = "dataset_#{dataset.id}_potentiostat_chart.png"
        puts "Moving #{old_filename} -> #{new_filename}"
        FileUtils.mv(old_filename, new_filename)
      end
    end
  end

  def self.down
  end
end

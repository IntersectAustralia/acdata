class AddTestMethodMetadataValueToPorometerDatasets < ActiveRecord::Migration
  def self.up
    #
    # YOU SHOULD NOT alter data with a migration. A rake task is the right way.
    #
    # So why am I doing it here?
    #
    # This is a one off retrofit to add a new row of data to a has_many
    # relationship. The latest code adds this, but the previous version didn't.
    #
    # The (Capillary Porometer) datasets created previous to the code change
    # are missing a metadata_value.
    #
    # A rake task for this would only be used once ever, and then would forever
    # sit unused in all new deployments of ACData.
    #
    porometer_instruments = Instrument.where(:instrument_class => 'Porometer')
    txt = InstrumentFileType.find_by_name('Capillary Porometer (.txt)')
    xls = InstrumentFileType.find_by_name('Capillary Porometer (.xls)')
    p_datasets = Dataset.where('instrument_id in (?)',
                                porometer_instruments.map(&:id))

    p_datasets.each do |d|
      next if d.metadata_values.where(:key => 'Test Method').present?

      att = d.attachments.where(
              'instrument_file_type_id in (?)', [xls,txt]).first
      next if att.nil?

      test_name = nil
      if att.filename =~ /\.xls/
        test_name =
          CapillaryPorometerXLSHandler.get_test_type_from_file(att.path)
      elsif att.filename =~ /.txt/
        test_name =
          CapillaryPorometerTXTHandler.get_test_type_from_file(att.path)
      end
      puts "Adding Test Method #{test_name} to #{d.name}"
      d.metadata_values.create!(:key => 'Test Method', :value => test_name)
    end
  end

  def self.down
    MetadataValues.where("key = 'Test Method' and value in (?)", CapillaryPorometerFileHandler::HANDLERS.values)
  end
end

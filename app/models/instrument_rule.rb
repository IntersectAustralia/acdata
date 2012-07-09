class InstrumentRule < ActiveRecord::Base

  belongs_to :instrument

  def exclusive_file_type_names
    @exclusive_list ||= list_from_csv(exclusive_list)
  end

  def exclusive_file_types
    @exclusive_files ||= InstrumentFileType.where(:name => exclusive_file_type_names)
  end

  def unique_file_type_names
    @unique_file_type_names ||= list_from_csv(unique_list)
  end

  def unique_file_types
    @unique_files ||= InstrumentFileType.where(:name => unique_file_type_names)
  end

  def indelible_file_type_names
    @indelible_file_type_names ||= list_from_csv(indelible_list)
  end

  def indelible_file_types
    @indelible_files ||= InstrumentFileType.where(:name => indelible_file_type_names)
  end

  def metadata_file_type_names
    @metadata_file_type_names ||= list_from_csv(metadata_list)
  end

  def metadata_file_types
    @metadata_files ||= InstrumentFileType.where(:name => metadata_file_type_names)
  end

  def visualisation_file_type_names
    @vis_file_type_names ||= list_from_csv(visualisation_list)
  end

  def visualisation_file_types
    @vis_file_types ||= InstrumentFileType.where(:name => visualisation_file_type_names)
  end

  def indelible?(instrument_file_type)
    if instrument_file_type.nil?
      false
    else
      metadata_file_type_names.include?(instrument_file_type.name) ||
        indelible_file_type_names.include?(instrument_file_type.name)
    end
  end

  def metadata?(instrument_file_type)
    if instrument_file_type.nil?
      false
    else
      metadata_file_type_names.include?(instrument_file_type.name)
    end
  end

  def visualisable?(instrument_file_type)
    if instrument_file_type.nil?
      false
    else
      visualisation_file_type_names.include?(instrument_file_type.name)
    end
  end

  private
  def list_from_csv(list)
    list.present? ? list.split(/\s*,\s*/) : []
  end

end

class DatasetRules

  def self.verify_from_filenames(dataset, filenames)
    result = {}
    filenames.each do |filename|
      if dataset.attachments.where(:filename => filename).empty?
        result[filename] = {:status => "proceed", :message => ""}
      else
        result[filename] = {:status => "abort", :message => "This file already exists."}
      end
    end
    result
  end

  def self.verify(new_attachments, dataset)
    result = {
      :verified => [],
      :rejected => []
    }
    instrument = dataset.instrument
    instrument_rules = instrument.instrument_rule
    attachments = dataset.attachments

    new_attachments.select{|a| a[:instrument_file_type].nil?}.each do |att|
      if attachments.select{|a| a[:filename] == att[:filename]}.empty?
        result[:verified] << att
      else
        result[:rejected] << [ att, "This file already exists." ]
      end
    end

    if instrument_rules.nil?
      new_attachments.select{|a| a[:instrument_file_type].present?}.each do |att|
        result[:verified] << att
      end
    else
      unique_count = {}
      xor_count = attachments.filter_by(instrument_rules.exclusive_file_type_names).count
      vis_count = attachments.filter_by(instrument_rules.visualisation_file_type_names).count

      new_attachments.select{|a| a[:instrument_file_type].present?}.each do |att|
        ft = att[:instrument_file_type]
        if instrument_rules.visualisable?(ft)
          if vis_count > 0
            result[:rejected] << [ att, "A visualisation file already exists." ]
            next
          else
            vis_count += 1
          end
        end

        filename = att[:filename]
        att_result = nil
        if must_be_unique?(ft, instrument_rules)
          unique_count[ft.name] ||= attachments.filter_by([ft.name]).count

          if unique_count[ft.name] > 0
            result[:rejected] << [ att, "A file of type '#{ft.name}' already exists in the dataset." ]
            next
          else
            unique_count[ft.name] += 1
          end

        end

        if must_be_exclusive?(ft, instrument_rules)
          if xor_count > 0
            result[:rejected] << [ att, "A similar file type already exists in the dataset." ]
            next
          else
            xor_count += 1
          end
        end
        result[:verified] << att
      end
    end

    result
  end

  private

  def self.must_be_unique?(instrument_file_type, rules)
    if instrument_file_type.nil?
      false
    else
      rules.unique_file_type_names.include?(instrument_file_type.name) ||
        rules.visualisable?(instrument_file_type) ||
        rules.metadata?(instrument_file_type)
    end
  end

  def self.must_be_exclusive?(instrument_file_type, rules)
    if instrument_file_type.nil?
      false
    else
      rules.exclusive_file_type_names.include?(instrument_file_type.name)
    end
  end


end

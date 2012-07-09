class Attachment < ActiveRecord::Base
  include ProjectZip

  belongs_to :dataset
  belongs_to :instrument_file_type

  validates :dataset, :presence => true
  validates :preview_mime_type, :presence => true, :unless => :no_preview?

  scope :filter_by, lambda { |file_type_name_list|
    joins(:instrument_file_type.outer).where(:instrument_file_type => [:name + file_type_name_list]) if file_type_name_list.present?
  }

  scope :inverse_filter_by, lambda { |file_type_name_list|
    joins(:instrument_file_type.outer).where({:instrument_file_type => [:name - file_type_name_list]} | (:instrument_file_type_id >> nil))
  }

  before_destroy do
    dataset.delete_metadata(self)
  end

  def no_preview?
    preview_file.blank?
  end

  def is_of_format?(required_format)
    format == required_format
  end

  def instrument_file?
    !instrument_file_type.nil?
  end

  def make_zip
    generate_zip(path, filename)
  end

  def sanitise_for_ie
    #the check could also be done with string#ascii_only? method
    out = filename.to_ascii #encode in ascii.
    out.bytesize != filename.bytesize ? "(renamed) " << out : out #if any 2-byte code points were replaced with 1-byte ascii, mark it as renamed
  end

  def file_extension
    File.extname(filename)[1..-1]
  end

  def parser
    if instrument_file_type.present?
      instrument_file_type.parser
    end
  end

  def set_indelible
    self.indelible = true
    save!(:validate => false)
  end

  def path
    File.join(dataset.dataset_path, filename)
  end

  def preview_file_path
    File.join(dataset.dataset_path, preview_file)
  end

  require 'find'

  def file_size

    size = 0
    Find.find(path) do |f|
      size += File.size(f) if File.file?(f)
    end
    size

  end

end

class Dataset < ActiveRecord::Base
  include ProjectZip

  FILES_ROOT = APP_CONFIG['files_root']

  belongs_to :sample
  belongs_to :instrument
  has_many :attachments, :dependent => :destroy
  has_many :metadata_values, :dependent => :destroy
  has_many :supplied_metadata, :dependent => :destroy, :class_name => "MetadataValue", :conditions => {:supplied => true, :core => true}
  has_many :eln_exports, :dependent => :destroy
  has_one :memre_export, :dependent => :destroy

  delegate :instrument_rule, :to => :instrument, :allow_nil => true
  delegate :name, :to => :instrument, :prefix => true

  validates_presence_of :sample
  validates_presence_of :name
  validates_presence_of :instrument_id
  validates_length_of :name, :maximum => 255
  validates_uniqueness_of :name, :case_sensitive => false, :scope => :sample_id, :message => "has been taken within this sample"

  accepts_nested_attributes_for :supplied_metadata, :allow_destroy => true, :reject_if => proc { |attrs| attrs['key'].blank? && attrs['value'].blank? }

  scope :name_ordered, order(:name)

  after_create :add_specific_metadata

  before_validation :strip_whitespace

  # TODO: preserve these instead for inevitable "undelete" feature
  before_destroy :delete_files

  after_save do
    @dataset_path = nil
  end

  def self.move_dataset(dataset, src)
    return if src == dataset.dataset_path
    dest = dataset.sample.sample_path
    logger.debug("Moving dataset files: #{src} -> #{dest}")
    begin
      if File.directory?(src)
        unless File.exists?(dest)
          logger.debug("move_dataset: creating #{dest}")
          FileUtils.mkpath(dest)
        end
        FileUtils.mv src, dest
      else
        raise "#{src} is NOT a directory"
      end
    rescue StandardError => e
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
      raise "There was an error in moving the dataset. Please contact an administrator"
    end
  end

  def add_specific_metadata

  end

  def strip_whitespace
    name.strip! if name
  end

  def dataset_path
    @dataset_path ||= File.join(FILES_ROOT, PathBuilder::Path.file_path(self))
  end

  def delete_files
    FileUtils.rm_rf dataset_path if File.exists?(dataset_path)
  end

  def metadata?
    metadata_values.present?
  end

  def delete_metadata(attachment)
    if attachment.present? and attachment.id.present?
      metadata_values.where(:attachment_id => attachment.id).delete_all
    end
  end

  def add_metadata(key, value, opts={})
    core = (opts.include?(:core) and opts[:core])
    supplied = (opts.include?(:supplied) and opts[:supplied])
    attachment = opts[:attachment]
    self.metadata_values.create!(:key => key,
                                 :value => value,
                                 :core => core,
                                 :supplied => supplied,
                                 :attachment => attachment)
  end

  def visual_attachment
    if self.instrument_rule
      vis_file_type_names = self.instrument_rule.visualisation_file_type_names
      unless vis_file_type_names.empty?
        return self.attachments.filter_by(vis_file_type_names).first
      end
    end
    nil
  end

  def visual_attachment_path(instrument_file_type_id = nil)
    if (instrument_file_type_id != nil)
      instrument_file_type = InstrumentFileType.find(instrument_file_type_id)
      attachment = attachments.filter_by([instrument_file_type.name]).first
    else
      attachment = self.visual_attachment
    end

    return nil if attachment.nil?
    file_type = attachment.instrument_file_type
    if file_type
      creator = file_type.visualisation_handler
      if creator
        Object::const_get(creator).display_file(attachment)
      else
        attachment.path
      end
    end
  end

  def summary_for_api
    name
  end

  private

end

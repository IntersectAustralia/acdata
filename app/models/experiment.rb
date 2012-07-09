class Experiment < ActiveRecord::Base

  belongs_to :project
  has_many :samples, :as => :samplable, :dependent => :destroy
  has_attached_file :document,
                    :path => lambda { |a| File.join(APP_CONFIG['files_root'], "/project_:proj_id/experiment_:id/:attachment/:basename.:extension") },
                    :url => "/projects/:proj_id/experiments/:id/collect_document"

  validates_presence_of :name
  validates_length_of :name, :maximum => 255
  validates_length_of :description, :maximum => 5000
  validates :url, :length => {:maximum => 2048}, :url_format => true
  validates_uniqueness_of :name, :case_sensitive => false, :scope => :project_id, :message => "has been taken within this project"
  validates_attachment_size :document, :less_than => APP_CONFIG['document_max_mib'].megabytes, :message => "must be less than #{APP_CONFIG['document_max_mib']} megabytes"


  scope :name_ordered, order(:name)


  before_validation do
    name.strip! if name
  end

  before_destroy do
    FileUtils.rm_rf experiment_path if File.exists?(experiment_path)
  end

  after_save do
    @experiment_path = nil
  end

  def self.move_experiment(experiment, src)

    dest = experiment.experiment_path
    return if src == dest
    logger.debug("Moving experiment files: #{src} -> #{dest}")
    begin
      if File.directory?(src)
        unless File.exists?(dest)
          logger.debug("move_experiment: creating #{dest}")
          FileUtils.mkpath(dest)
        end
        FileUtils.mv Dir.glob("#{src}/*"), dest
      else
        logger.error("move_experiment: #{src} is NOT a directory")
      end
    rescue StandardError => e
      experiment.errors.add(:base, "There was an error in moving the experiment. Please contact an administrator")
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
      raise ActiveRecord::Rollback
    end

  end

  def experiment_path
    @experiment_path ||= File.join(APP_CONFIG['files_root'], PathBuilder::Path.file_path(self))
  end

  def document_display_name
    PathBuilder::Path.filename_trunc(document.original_filename, APP_CONFIG['filename_display_length'])
  end

  def url_domain
    host = begin
      URI::parse(self.url).host
    rescue #Why catch 'em all? because the short url is just a convenience so we don't care if it fails.
      nil
    end
    host.present? ? "via #{host}" : self.url.truncate(APP_CONFIG['filename_display_length'])
  end

  def summary_for_api(options={})
    summary = {
        :id => id,
        :name => name
    }
    if options[:samples] != false
      summary[:samples] = samples.map { |s| s.summary_for_api(options) }
    end
    summary
  end
end

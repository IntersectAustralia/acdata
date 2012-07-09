class Sample < ActiveRecord::Base
  FILES_ROOT = APP_CONFIG['files_root']
 
  belongs_to :samplable, :polymorphic => true

  has_many :datasets, :dependent => :destroy

  validates_presence_of :name
  validates_length_of :name, :maximum => 255
  validates_length_of :description, :maximum => 5000

  validates_presence_of :samplable_id
  validates_inclusion_of :samplable_type, :in => %w( Experiment Project ), :message => "Type '%s' neither 'Project' or 'Experiment'"

  scope :name_ordered, order(:name)


  before_validation do
    name.strip! if name
  end

  before_destroy do
    FileUtils.rm_rf sample_path if File.exists?(sample_path)
  end

  after_save do
    @sample_path = nil
  end

  def self.move_sample(sample, src)
    dest = sample.sample_path
    return if src == dest
    logger.debug("Moving sample files: #{src} -> #{dest}")
    begin
      if File.directory?(src)
        unless File.exists?(dest)
          logger.debug("move_sample: creating #{dest}")
          FileUtils.mkpath(dest)
        end
        FileUtils.mv Dir.glob("#{src}/*"), dest
      else
        logger.error("move_sample: #{src} is NOT a directory")
      end
    rescue StandardError => e
      sample.errors.add(:base, "There was an error in moving the sample. Please contact an administrator")
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
      raise ActiveRecord::Rollback
    end
  end

  #def move_sample(sample, src)
  #  dest = sample.sample_path
  #  logger.debug("Moving sample files: #{src} -> #{dest}")
  #  return if src == dest
  #  if File.directory?(src)
  #    if !File.exists?(dest)
  #      FileUtils.mkpath(dest)
  #    end
  #    FileUtils.mv Dir.glob("#{src}/*"), dest
  #    FileUtils.remove_dir src
  #  else
  #    logger.error("move_sample: #{src} is NOT a directory")
  #  end
  #end
  #
  def nav_name
    if name_unique_in_container?
      name
    else
      "#{name} (#{id})"
    end
  end

  def select_name
    if samplable.is_a?(Experiment)
      "#{samplable.name}: #{nav_name}"
    else
      nav_name
    end
  end

  def sample_path
    @sample_path ||= File.join(APP_CONFIG['files_root'], PathBuilder::Path.file_path(self))
  end

  def summary_for_api(options={})
    {
      :id => id,
      :name => name,
      :datasets => datasets.map { |dataset| dataset.summary_for_api }
    }
  end

  def has_dataset_with_name?(dataset_name)
    self.datasets.where(:name => dataset_name).size > 0
  end

  def has_attachments?
    datasets.collect(&:attachments).flatten.present?
  end

  private
  def name_unique_in_container?
    Sample.where(
      :name => name,
      :samplable_type => samplable_type,
      :samplable_id => samplable_id
    ).count <= 1
  end

end

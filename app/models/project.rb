class Project < ActiveRecord::Base
  belongs_to :user

  has_many :memberships, :class_name => "ProjectMember"
  has_many :viewerships, :class_name => "ProjectMember", :conditions => {:collaborating => false}
  has_many :collaborations, :class_name => "ProjectMember", :conditions => {:collaborating => true}

  has_many :members,
           :through => :memberships,
           :class_name => 'User',
           :source => :user

  has_many :viewers,
           :through => :viewerships,
           :class_name => 'User',
           :source => :user

  has_many :collaborators,
           :through => :collaborations,
           :class_name => 'User',
           :source => :user

  has_many :experiments, :dependent => :destroy
  has_many :samples, :as => :samplable, :dependent => :destroy
  has_one :ands_publishable

  has_one :activity

  scope :name_ordered, order(:name)

  has_attached_file :document,
                    :path => lambda { |a| File.join(APP_CONFIG['files_root'], "/project_:id/:attachment/:filename") },
                    :url => "/projects/:id/collect_document"



  accepts_nested_attributes_for :memberships
  accepts_nested_attributes_for :members
  accepts_nested_attributes_for :viewers
  accepts_nested_attributes_for :collaborators

  validates :name, :presence => true
  validates_uniqueness_of :name, :scope => :user_id, :case_sensitive => false
  validates_length_of :name, :maximum => 255
  validates_length_of :description, :maximum => 5000
  validates :url, :length => {:maximum => 2048}, :url_format => true
  validates_attachment_size :document, :less_than => APP_CONFIG['document_max_mib'].megabytes , :message => "must be less than #{APP_CONFIG['document_max_mib']} megabytes"

  before_validation do
    name.strip! if name
  end

  before_destroy do
    FileUtils.rm_rf project_path if File.exists?(project_path)
  end

  after_save do
    @project_path = nil
  end

  def project_path
    @project_path ||= File.join(APP_CONFIG['files_root'], PathBuilder::Path.file_path(self))
  end

  def document_display_name
    PathBuilder::Path.filename_trunc(document.original_filename, APP_CONFIG['filename_display_length'])
  end

  def get_instruments

    instruments = []

    #find_each
    self.samples.find_each do |sample|
      instruments += sample.datasets.collect(&:instrument)
    end

    self.experiments.find_each do |experiment|
      experiment.samples.find_each do |sample|
        instruments += sample.datasets.collect(&:instrument)
      end
    end

    instruments.uniq
  end

  def has_eln_export?
    self.samples.find_each do |sample|
      sample.datasets.find_each do |dataset|
        return true if dataset.eln_exports.present?
      end
    end

    self.experiments.find_each do |experiment|
      experiment.samples.find_each do |sample|
        sample.datasets.find_each do |dataset|
          return true if dataset.eln_exports.present?
        end
      end
    end

    return false
  end

  def has_memre_export?

    return false
  end

  def published?
    ands_publishable.present? ? ands_publishable.published? : false
  end

  def url_domain
    host = begin
      URI::parse(self.url).host
    rescue #Why catch 'em all? because the short url is just a convenience so we don't care if it fails.
      nil
    end
    host.present? ? "via #{host}" : self.url.truncate(APP_CONFIG['filename_display_length'])
  end

  def owner?(u)
    user == u
  end

  def change_owner(new_owner)
    current_owner = user
    self.user = new_owner
    self.members.delete new_owner
    self.members << current_owner
    save!
  end

  def can_remove?(user)
    self.members.include?(user) and !self.user.id.eql?(user.id)
  end

  def summary_for_api(options={})
    summary = {
      :id => id,
      :name => name,
      :experiments => experiments.map { |e| e.summary_for_api(options) },
    }
    unless options[:samples] == false
      summary[:samples] = samples.map { |s| s.summary_for_api(options) }
    end
    summary
  end

  def self.as_json_tree(owned, collaborating)
    {
      :owner => owned.map { |p| p.summary_for_api },
      :collaborator => collaborating.map { |p| p.summary_for_api }
    }
  end

end

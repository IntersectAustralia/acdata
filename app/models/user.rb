class User < ActiveRecord::Base
  # Include devise modules
  devise :ldap_authenticatable, :recoverable, :registerable, :trackable, :timeoutable, :token_authenticatable

  belongs_to :role
  has_many :projects
  has_many :eln_blogs, :dependent => :destroy

  has_many :ands_publishables, :foreign_key => :moderator_id

  has_many :memberships, :class_name => "ProjectMember"
  has_many :viewerships, :class_name => "ProjectMember", :conditions => {:collaborating => false}
  has_many :collaborations, :class_name => "ProjectMember", :conditions => {:collaborating => true}

  has_many :project_memberships,
           :through => :memberships,
           :class_name => 'Project',
           :source => :project

  has_many :project_viewerships,
           :through => :viewerships,
           :class_name => 'Project',
           :source => :project

  has_many :project_collaborations,
           :through => :collaborations,
           :class_name => 'Project',
           :source => :project

  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :email, :first_name, :last_name, :phone_number, :eln_blogs_attributes,
                  :authentication_token, :nmr_username, :supervisor_name, :supervisor_email, :is_student,
                  :eln_enabled, :memre_enabled, :nmr_enabled, :slide_request_enabled

  accepts_nested_attributes_for :eln_blogs, :allow_destroy => true, :reject_if => lambda { |a| a[:name].blank? }

  before_validation :initialize_status
  before_validation :strip_fields


  # regex from devise :validatable module
  validates :email, :presence => true, :format => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/

  validates :supervisor_name, :presence => true, :length => {:maximum => 255}, :if => :student?
  validates :supervisor_email, :presence => true, :length => {:maximum => 255}, :if => :student?

  validates_format_of :supervisor_email, :with => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/, :allow_blank => true, :if => :student?

  validates_length_of :nmr_username, :maximum => 3
  validates_format_of :nmr_username, :with => /^[a-zA-Z0-9]+$/, :allow_blank => true
  validates_uniqueness_of :nmr_username, :case_sensitive => false, :allow_blank => true

  validates_presence_of :nmr_username, :if => Proc.new { |u| u.nmr_enabled? }
  validates_presence_of :phone_number, :if => Proc.new { |u| u.slide_request_enabled? }, :message => "must be provided for Slide Scanning Service requests"

  scope :pending_approval, where(:status => 'U').order(:login)
  scope :approved, where(:status => 'A').order(:login)
  scope :deactivated_or_approved, where("status = 'D' or status = 'A'").order(:login)
  scope :approved_superusers, joins(:role).merge(User.approved).merge(Role.superuser_roles)
  scope :approved_moderators, joins(:role).merge(User.approved).merge(Role.moderator_roles)

  def strip_fields
    supervisor_name.strip! if supervisor_name
    supervisor_email.strip!  if supervisor_email
    phone_number.strip! if phone_number
  end

  def student?
    self.is_student?
  end

  def get_supervisor_name
    is_student? ? supervisor_name : "#{first_name} #{last_name}"
  end

  def get_supervisor_email
    is_student? ? supervisor_email : email

  end

  def after_token_authentication
    update_attributes :authentication_token => nil
  end

  def self.potential_members(name_part)
    escaped_name_part = name_part.gsub('%', '\%').gsub('_', '\_')
    name_start = escaped_name_part + '%'
    approved.where((:first_name.matches % name_start | :last_name.matches % name_start)).select('first_name, last_name, email, id').order(:first_name, :last_name)
  end

  def can_read_projects
    project_ids + project_membership_ids
  end

  def can_manage_projects
    project_ids + project_collaboration_ids
  end

  def can_read_experiments
    Experiment.find_all_by_project_id(can_read_projects).collect(&:id)
  end

  def can_manage_experiments
    Experiment.find_all_by_project_id(can_manage_projects).collect(&:id)
  end

  def can_manage_ands_publishables
    AndsPublishable.find_all_by_project_id(can_manage_projects).collect(&:id)
  end

  def can_read_samples
    pids = can_read_projects
    eids = can_read_experiments
    get_sample_ids(pids, eids)
  end

  def can_manage_samples
    pids = can_manage_projects
    eids = can_manage_experiments
    get_sample_ids(pids, eids)
  end

  def can_read_datasets
    Dataset.find_all_by_sample_id(can_read_samples).collect(&:id)
  end

  def can_manage_datasets
    Dataset.find_all_by_sample_id(can_manage_samples).collect(&:id)
  end

  def can_manage_attachments
    Attachment.find_all_by_dataset_id(can_manage_datasets).collect(&:id)
  end

  def indelible_attachments
    Attachment.where(:indelible => true).find_all_by_dataset_id(can_manage_datasets).collect(&:id)
  end

  def can_read_attachments
    Attachment.find_all_by_dataset_id(can_read_datasets).collect(&:id)
  end

  def active_for_authentication?
    super && approved?
  end

  # Overrride Devise method to prevent password changes
  def send_reset_password_instructions
    set_flash_message :error, :change_password
  end

  # Overrride Devise method to prevent password changes
  def update_password(params={})
    set_flash_message :error, :change_password
  end

  def approved?
    self.status == 'A'
  end

  def pending_approval?
    self.status == 'U'
  end

  def deactivated?
    self.status == 'D'
  end

  def deactivate
    self.status = 'D'
    save!(:validate => false)
  end

  def activate
    self.status = 'A'
    save!(:validate => false)
  end

  def reject
    self.status = 'R'
    save!(:validate => false)
  end

  def rejected?
    self.status == 'R'
  end

  def check_number_of_superusers(id, current_user_id)
    current_user_id != id.to_i or User.approved_superusers.length >= 2

  end

  def self.get_superuser_emails
    approved_superusers.collect { |u| u.email }
  end

  def full_name
    full_name = self.first_name
    full_name += ' ' + self.last_name if (!self.last_name.nil?)
    return full_name
  end

  def full_name_and_email
    return full_name + " (#{self.email})"
  end

  def is_superuser?
    self.role.name.eql?("Superuser")
  end

  def is_moderator?
    self.role.name.eql?("Moderator")
  end

  private

  def initialize_status
    self.status = "U" unless self.status
  end

  def get_sample_ids(pids, eids)
    sample_ids_by_project =
        Sample.find_all_by_samplable_id(pids).collect { |p| p.id }

    sample_ids_by_experiment =
        Sample.find_all_by_samplable_id(eids).collect { |e| e.id }
    (sample_ids_by_experiment + sample_ids_by_project).uniq
  end

end

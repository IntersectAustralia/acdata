class Role < ActiveRecord::Base

  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}
  has_many :users
  scope :by_name, order('name')
  scope :superuser_roles, where(:name => 'Superuser')  #TODO: put your superuser role name in here
  scope :moderator_roles, where(:name => 'Moderator')  #TODO: put your superuser role name in here

  def self.get_superuser_emails
    User.approved_superusers.collect { |u| u.email }
  end

  def self.get_moderator_emails
    User.approved_moderators.collect { |u| u.email }
  end

end

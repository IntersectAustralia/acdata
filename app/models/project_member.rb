class ProjectMember < ActiveRecord::Base

  belongs_to :user
  belongs_to :project

#  default_scope :order => 'collaborating desc'
end

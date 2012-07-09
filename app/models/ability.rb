class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :edit_role, :to => :update_role
    alias_action :edit_approval, :to => :approve

    # alias activate and deactivate to "activate_deactivate" so its just a single permission
    alias_action :deactivate, :to => :activate_deactivate
    alias_action :activate, :to => :activate_deactivate

    # alias access_requests to view_access_requests so the permission name is more meaningful
    alias_action :access_requests, :to => :admin

    # alias access_requests to view_access_requests so the permission name is more meaningful
    alias_action :ands_publishable_requests, :to => :moderate

    # alias reject_as_spam to reject so they are considered the same
    alias_action :reject_as_spam, :to => :reject

    # alias remove_member to edit_member so collaborator privileges are more well defined
    alias_action :remove_member, :to => :edit_member

    # Superuser privileges
    is_superuser = user.is_superuser?
    can :admin, User if is_superuser
    can :read, User if is_superuser
    can :update_role, User if is_superuser
    can :activate_deactivate, User if is_superuser
    can :approve, User if is_superuser
    can :reject, User if is_superuser
    can :manage, Instrument if is_superuser
    can :manage, Settings if is_superuser

    can :list, User
    can :list, Instrument
    can :list_for_codes, AndsPublishable
    can :list_seo_codes, AndsPublishable
    can :list_subject_keywords, AndsPublishable
    can :list_ands_parties, AndsPublishable
    can :create_and_add_attachments, Dataset

    # Moderator privileges
    is_moderator = user.is_moderator? || user.is_superuser?
    can :moderate, User if is_moderator
    can :approve, AndsPublishable, :moderator_id => user.id if is_moderator
    can :reject, AndsPublishable, :moderator_id => user.id if is_moderator
    can :preview, AndsPublishable, :moderator_id => user.id if is_moderator
    can :reject_reason, AndsPublishable, :moderator_id => user.id if is_moderator
    can :download, AndsPublishable, :moderator_id => user.id if is_moderator

    project_ownerships = user.project_ids
    project_collaborations = user.project_collaboration_ids + user.project_ids
    project_memberships = user.project_membership_ids + user.project_ids

    # Project privileges
    can :list, Project, :id => project_collaborations
    can :create, Project
    can :slide_guidelines_pdf, Project
    can :read, Project, :id => project_memberships
    can :download, Project, :id => project_memberships
    can :update, Project, :id => project_collaborations
    can :destroy, Project, :id => project_ownerships
    can :delete_document, Project, :id => project_collaborations
    can :collect_document, Project, :id => project_memberships
    can :sample_select, Project, :id => project_collaborations
    can :show_publishable_data, Project, :id => project_collaborations
    can :save_sample_select, Project, :id => project_collaborations
    can :request_slide_scanning, Project, :id => project_collaborations
    can :send_slide_request, Project, :id => project_collaborations
    can :edit_member, Project, :id => project_ownerships
    can :leave, Project do |project|
      project.can_remove?(user)
    end
    can :make_owner, Project, :id => project_ownerships


    # Experiment privileges
    can :manage, Experiment, :project_id => project_collaborations
    can :read, Experiment, :project_id => project_memberships
    can :collect_document, Experiment, :project_id => project_memberships
    can :download, Experiment, :project_id => project_memberships

    # Sample privileges
    can :manage, Sample, :id => user.can_manage_samples
    can :read, Sample, :id => user.can_read_samples
    can :create_sample, Project do |project|
      project_collaborations.include?(project.id)
    end

    # Dataset privileges
    can_manage_dataset = user.can_manage_datasets
    can_read_dataset = user.can_read_datasets
    can :manage, Dataset, :id => can_manage_dataset
    can :read, Dataset, :id => can_read_dataset
    can :download, Dataset, :id => can_read_dataset
    can :create, Dataset, :sample_id => user.can_manage_samples
    can :show_display_attachment, Dataset, :id => can_read_dataset
    can :metadata, Dataset, :id => can_read_dataset

    # Export to MemRE
    can :read, MemreExport, :dataset_id => can_read_dataset
    can :update, MemreExport, :dataset_id => can_read_dataset

    # Ands Publishable privileges
    can :manage, AndsPublishable, :project_id => project_collaborations

    # Activity privileges
    can :manage, Activity, :project_id => project_collaborations

    # ELN Exports
    can :update, ElnExport, :dataset_id => can_read_dataset
    can :destroy, ElnExport, :dataset_id => can_read_dataset

    # Attachment privileges
    can :manage, Attachment, :id => user.can_manage_attachments
    can :download, Attachment, :id => user.can_read_attachments
    can :preview, Attachment, :id => user.can_read_attachments


    # cannot destroy any metadata attachments
    cannot :destroy, Attachment, :id => user.indelible_attachments

  end
end

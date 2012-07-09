class Notifier < ActionMailer::Base

  PREFIX = "ACData - "

  def notify_user_of_sent_request(recipient)
    @user = recipient
    mail(:to => @user.email,
         :from => APP_CONFIG['account_request_user_status_email_sender'],
         :reply_to => APP_CONFIG['account_request_user_status_email_sender'],
         :subject => PREFIX + "Your access request has been received")
  end


  def notify_user_of_approved_request(recipient)
    @user = recipient
    mail(:to => @user.email,
         :from => APP_CONFIG['account_request_user_status_email_sender'],
         :reply_to => APP_CONFIG['account_request_user_status_email_sender'],
         :subject => PREFIX + "Your access request has been approved")
  end

  def notify_user_of_rejected_request(recipient)
    @user = recipient
    mail(:to => @user.email,
         :from => APP_CONFIG['account_request_user_status_email_sender'],
         :reply_to => APP_CONFIG['account_request_user_status_email_sender'],
         :subject => PREFIX + "Your access request has been rejected")
  end

  # notifications for super users
  def notify_superusers_of_access_request(applicant)
    superusers_emails = User.get_superuser_emails
    @user = applicant
    mail(:to => superusers_emails,
         :from => APP_CONFIG['account_request_admin_notification_sender'],
         :reply_to => @user.email,
         :subject => PREFIX + "There has been a new access request")
  end

  def notify_moderator_of_publishable(ands_publishable)
    @ands_publishable = ands_publishable
    @moderator = ands_publishable.moderator
    @project = ands_publishable.project
    @user = @project.user

    mail(:to => @moderator.email,
         :from => APP_CONFIG['ands_publishable_moderator_notification_sender'],
         :reply_to => @user.email,
         :subject => PREFIX + "A new RDA publishable is pending approval")
  end

  def notify_user_of_approved_publishable_request(ands_publishable)
    @ands_publishable = ands_publishable
    @moderator = ands_publishable.moderator
    @project = ands_publishable.project
    @user = @project.user
    mail(:to => @user.email,
         :from => @moderator.email,
         :reply_to => @moderator.email,
         :subject => PREFIX + "Your RDA publishable request has been approved")
  end

  def notify_user_of_rejected_publishable_request(ands_publishable, reason)
    @ands_publishable = ands_publishable
    @moderator = ands_publishable.moderator
    @project = ands_publishable.project
    @user = @project.user
    @reason = reason
    mail(:to => @user.email,
         :from => @moderator.email,
         :reply_to => @moderator.email,
         :subject => PREFIX + "Your RDA publishable request has been rejected")
  end

  def send_slide_request_email(params)
    @project = Project.find(params[:project_id])
    @user = User.find(params[:user_id])
    emails = [@user.get_supervisor_email, Settings.instance.slide_scanning_email]
    @params = params
    mail(:to => emails,
         :from => APP_CONFIG['slide_scanning_request_notification_sender'],
         :reply_to => APP_CONFIG['slide_scanning_request_notification_sender'],
         :subject => PREFIX + "There has been a new slide scanning service request by #{@user.full_name}")
  end

  def notify_user_of_slide_request(params)
    @project = Project.find(params[:project_id])
    @user = User.find(params[:user_id])
    @params = params
    mail(:to => @user.email,
         :from => APP_CONFIG['slide_scanning_request_notification_sender'],
         :reply_to => APP_CONFIG['slide_scanning_request_notification_sender'],
         :subject => PREFIX + "Your slide scanning service request has been received")
  end

  def notification_from_api(recipient, subject, message)
    @message = message
    mail(:to => recipient.email,
         :from => recipient.email,
         :subject => subject)
  end

end

class UsersController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @users = User.deactivated_or_approved
  end

  def show
  end

  def admin
  end

  def list
    respond_to do |f|
      f.json do
        q = params[:term]
        if q.blank?
          render :json => nil and return
        end
        potential_members = User.potential_members(q)
        potential_members.delete_if { |user| user == current_user }
        users = Array.new
        potential_members.collect do |u|
          label = "#{u.first_name} #{u.last_name} (#{u.email})"
          users << Hash[:id => u.id, :label => label, :value => "#{u.first_name} #{u.last_name}"]
        end
        render :json => users
      end
    end
  end

  def access_requests
    @users = User.pending_approval
  end

  def ands_publishable_requests

    @ands_publishables = current_user.ands_publishables.where(:status => 'S')
  end

  def reject_access_request
    @user.reject

    # send an email to the user
    begin
      Notifier.notify_user_of_rejected_request(@user).deliver
    rescue Exception => e
      flash.now[:alert] = "Sending notification to #{@user.email} failed"
      logger.warn("Notification failed: #{e.message}")
    end
  end

  def deactivate
    if !@user.check_number_of_superusers(params[:id], current_user.id)
      redirect_to(@user, :alert => "Only one superuser exists. You cannot deactivate this account.")
    else
      @user.deactivate
      redirect_to(@user, :notice => "The user has been deactivated.")
    end
  end

  def activate
    @user.activate
    redirect_to(@user, :notice => "The user has been activated.")
  end

  def reject
    reject_access_request
    @user.destroy
    redirect_to(access_requests_users_path, :notice => "The access request for #{@user.full_name} was rejected.")
  end

  def reject_as_spam
    reject_access_request
    redirect_to(access_requests_users_path, :notice => "The access request for #{@user.full_name} was rejected and this user will be permanently blocked.")
  end

  def edit_role
    if @user == current_user
      flash[:alert] = "You are changing the role of the user you are logged in as."
    elsif @user.rejected?
      redirect_to(users_path, :alert => "Role can not be set. This user has previously been rejected as a spammer.")
    end
    @roles = Role.by_name
  end

  def edit_approval
    @roles = Role.by_name
  end

  def update_role
    if params[:user][:role_id].blank?
      redirect_to(edit_role_user_path(@user), :alert => "Please select a role for the user.")
    elsif @user.rejected?
      redirect_to(access_requests_users_path, :alert => "Role can not be set. This user has previously been rejected as a spammer.")
    else
      @user.role_id = params[:user][:role_id]
      if !@user.check_number_of_superusers(params[:id], current_user.id)
        redirect_to(edit_role_user_path(@user), :alert => "Only one superuser exists. You cannot change this role.")
      elsif @user.save
        redirect_to(@user, :notice => "The role for #{@user.full_name} was successfully updated.")
      end
    end
  end

  def approve
    if !params[:user][:role_id].blank?
      @user.role_id = params[:user][:role_id]
      @user.save!

      begin
        approve_access_request
      rescue Exception => e
        flash.now[:alert] = "Sending notification to #{@user.email} failed"
        logger.warn("Notification failed: #{e.message}")
      end

      redirect_to(access_requests_users_path, :notice => "The access request for #{@user.full_name} was approved.")
    else
      redirect_to(edit_approval_user_path(@user), :alert => "Please select a role for the user.")
    end
  end

  private

  def approve_access_request
    @user.activate

    # send an email to the user
    Notifier.notify_user_of_approved_request(@user).deliver
  end

end

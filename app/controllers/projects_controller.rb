require 'aperio_client'

class ProjectsController < ApplicationController

  respond_to :js, :only => [:new, :edit, :create, :update, :sample_select, :delete_document, :request_slide_scanning]

  before_filter :authenticate_user!
  before_filter :projects_and_memberships, :only => [:show, :index, :sample_select, :show_publishable_data, :list, :request_slide_scanning]

  include DatasetsHelper
  include ProjectsHelper
  include ProjectZip

  load_and_authorize_resource :except => [:create]

  def index
  end

  def new

  end

  def edit

  end

  def show
    @sample = Sample.new
  end

  def list
    respond_to do |format|
      format.json {
        render :json => Project.as_json_tree(@projects, @collaborations)
      }
    end
  end

  def sample_select
    @dataset = Dataset.new
    @samples = @project.samples + @project.experiments.collect(&:samples).flatten
    render :template => 'shared/sample_select'
  end

  def create
    params.delete(:member_zid)
    params.delete(:member)
    members = params[:project].delete(:member_ids)
    collaborators = params[:project].delete(:collaborating)

    if collaborators
      params[:project][:collaborator_ids] = collaborators.keys
      params[:project][:viewer_ids] = members - collaborators.keys
    else
      params[:project][:collaborator_ids] = []
      params[:project][:viewer_ids] = members
    end

    @project = Project.new(params[:project])
    @project.user = current_user
    if @project.save
      @redirect_path = project_url(@project)
      flash[:notice] = "Project was successfully created."
    else
      @redirect_path = nil
    end
  end

  def update
    @project = Project.find(params[:id])
    params.delete(:member)
    params[:project][:member_ids] = [] if params[:project][:member_ids].blank?
    members = params[:project].delete(:member_ids)
    collaborators = params[:project].delete(:collaborating)

    if collaborators
      params[:project][:collaborator_ids] = collaborators.keys
      params[:project][:viewer_ids] = members - collaborators.keys
    else
      params[:project][:collaborator_ids] = []
      params[:project][:viewer_ids] = members
    end

    if @project.update_attributes(params[:project])
      @redirect_path = project_url(@project)
      flash[:notice] = "Project was successfully updated."
    else
      @redirect_path = nil
    end
  end

  def destroy
    @project = Project.find(params[:id])
    if @project.destroy
      redirect_to projects_url, :notice => "The project #{@project.name} has been successfully removed."
    else
      redirect_to :back, :alert => "The project #{@project.name} could not be deleted."
    end
  end

  def leave
    if @project.can_remove?(current_user)
      @project.members.delete(current_user)
      redirect_to projects_path, :notice => "You have been removed from #{@project.name}."
    else
      redirect_to projects_path, :alert => "You cannot be removed from #{@project.name}."
    end
  end

  def remove_member
    @project = Project.find(params[:id])
    user_id = params[:user_id]
    @project.members.delete(User.find(user_id)) if user_id

    redirect_to @project
  end

  def make_owner
    @project = Project.find(params[:id])

    user_id = params[:user_id]
    return unless user_id

    new_owner = User.find(user_id)
    return unless new_owner

    @project.change_owner(new_owner)

    redirect_to @project
  end

  def download
    @project = Project.find(params[:id])
    begin
      if has_attachments?(@project)
        zipfile = generate_project_zip(@project)
        File.open(zipfile, 'r') do |f|
          send_data f.read, :filename => "#{@project.name.to_filename}.zip"
        end
      else
        redirect_to project_path(@project), :alert => "No datasets to download from this project."
      end
    rescue Exception => e
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
      redirect_to projects_path, :alert => "Cannot download project"
    ensure
      logger.debug("Deleting zip: #{zipfile}")
      File.delete(zipfile) if zipfile
    end
  end

  def collect_document
    if @project.document.present?
      send_file @project.document.path, :filename => @project.document.original_filename
    else
      redirect_to project_path(@project), :alert => "The project #{@project.name} has no supplementary document."
    end
  end

  def delete_document
    @project.document.destroy
    @project.document = nil
    @project.save
    flash[:notice] = "The related document has been successfully removed."
  end


  def show_publishable_data
    require "builder"
    xml = Builder::XmlMarkup.new(:indent => 2)
    if @project.ands_publishable
      send_data @project.ands_publishable.to_rif_cs(xml)
    else
      redirect_to project_path(@project), :alert => "No publishable data for this project."
    end
  end

  def request_slide_scanning
    @fluorescent_labels = FluorescentLabel.all.collect(&:name)
  end

  def send_slide_request

    begin

      unless @project.slide_request_sent
        aperio_client = AperioClient.new
        aperio_client.create_project :Name => @project.name,
                                     :Description => @project.description,
                                     :ContactName => "#{current_user.first_name} #{current_user.last_name}",
                                     :ContactEmail => current_user.email,
                                     :ContactPhone => current_user.phone_number,
                                     :ReferenceLab => params["slide"]["reference_lab"],
                                     :ColumnEthics_No => params["slide"]["approval_number"],
                                     :ColumnACData_ID => @project.id,
                                     :ColumnACDataUpdate => 'No'
        aperio_client.close
        @project.slide_request_sent = true
        @project.save!

      end
    rescue Exception => ex
      logger.error(ex.message)
      logger.error(ex.backtrace.join("\n"))
      redirect_to project_path(@project), :alert => "Could not send slide scanning request. Please try again or contact an administrator."

    else
      Notifier.send_slide_request_email(params["slide"]).deliver
      Notifier.notify_user_of_slide_request(params["slide"]).deliver if current_user.is_student?
      redirect_to project_path(@project), :notice => "You have successfully lodged a request for slide scanning services. You may now submit your slides for scanning."

    end
  end

  def slide_guidelines_pdf

    send_data(generate_guidelines_pdf, :filename => "slide_guidelines.pdf", :type => 'application/pdf')

  end

  private
  def generate_guidelines_pdf
    require 'prawn'
    Prawn::Document.new do |pdf|

      pdf.text "Slide Scanning Service Guidelines", :size => 20, :align => :center
      pdf.move_down 50

      Settings.instance.slide_guidelines.each_with_index do |guideline, index|
        pdf.text "#{index + 1}. " + guideline.description, :size => 10
        pdf.move_down 10
      end

    end.render
  end
end

class AndsPublishablesController < ApplicationController

  respond_to :js, :only => [:new, :edit, :create, :update, :preview, :reject_reason, :reject]

  before_filter :authenticate_user!
  before_filter :projects_and_memberships, :only => [:show, :index]

  load_and_authorize_resource :project, :except => [:approve, :reject, :preview, :reject_reason]
  load_and_authorize_resource :ands_publishable,
                              :through => :project, :singleton => true,
                              :except => [:approve, :reject, :preview, :reject_reason, :list_for_codes, :list_seo_codes, :list_subject_keywords, :list_ands_parties, :download]
  # moderators do not necessarily belong to the project
  load_and_authorize_resource :ands_publishable,
                              :only => [:approve, :reject, :preview, :reject_reason, :list_for_codes, :list_seo_codes, :list_subject_keywords, :list_ands_parties, :download]


  layout 'projects'

  expose(:moderators) { (User.approved_moderators + User.approved_superusers).collect { |a| [a.full_name, a.id] }.uniq.sort }
  expose(:titles) { ["Ms.", "Mr.", "Mrs.", "Miss", "Dr.", "Prof."] }

  def download
    require "builder"
    xml = Builder::XmlMarkup.new(:indent => 2)
    send_data @ands_publishable.to_rif_cs(xml), :filename => "#{@ands_publishable.collection_name}.xml"
  end

  def submit
    begin
      Notifier.notify_moderator_of_publishable(@ands_publishable).deliver
      flash[:notice] = "The project's publishable data was successfully created and is pending approval by #{@ands_publishable.moderator.full_name}"
      @ands_publishable.submit
    rescue
      flash[:alert] = "The project's publishable data was created but request cannot be sent to the moderator, please try again later"
    end
    redirect_to project_path(@ands_publishable.project_id)
  end

  def new
    @ands_publishable = @project.ands_publishable

    if @ands_publishable
      render :edit
    else
      @ands_publishable = AndsPublishable.new
      @ands_publishable.address = APP_CONFIG['default_address']
      @ands_publishable.collection_name = @project.name
      @ands_publishable.collection_description = @project.description

    end

  end

  def edit
  end

  def create
    @ands_publishable = @project.create_ands_publishable(params[:ands_publishable])

    if @ands_publishable.save
      render :specify_related_info
    else
      @redirect_path = nil
    end
  end

  def specify_related_info

  end

  def related_info_specified

    if params[:ands_publishable]
      ands_subjects = params[:ands_publishable][:ands_subject_ids] || []
      new_subjects = ands_subjects.select { |a| a[/^new_/] }
      # join existing ands_subjects
      @ands_publishable.ands_subject_ids = ands_subjects - new_subjects

      # create new subjects
      new_subjects.each do |keyword|
        extracted = keyword.sub(/new_/, "")

        @ands_publishable.ands_subjects.create(:keyword => extracted)
      end

      @ands_publishable.for_code_ids = params[:ands_publishable][:for_code_ids] || []

      related_info_attrs = params[:ands_publishable][:related_info] || {}
      # deletes anything not in the array
      @ands_publishable.ands_related_infos.where(:id - related_info_attrs.keys).destroy_all

      new_attrs = related_info_attrs.select { |key| key[/^new_/] }
      new_attrs.each do |key, value|
        @ands_publishable.ands_related_infos.create(value)
      end


    end

    if params[:commit].eql?("Next")
      set_party_form_variables
      render :specify_party_info
    else
      render :edit
    end

  end

  def specify_party_info
    set_party_form_variables

  end

  def party_info_specified


    if params[:ands_publishable]
      @ands_publishable.process_related_objects(params[:ands_publishable])


    end

    if params[:commit].eql?("Next")
      set_party_form_variables
      render :preview
    else
      render :specify_related_info

    end


  end

  def preview
    authorize! :preview, @ands_publishable
    set_party_form_variables
    @as_moderator = request.referrer.eql?(ands_publishable_requests_users_url)
  end


  def destroy
    if @ands_publishable.destroy
      redirect_to @project, :notice => params[:new] ? "The publishable creation process was cancelled." : "The publishable was successfully deleted!"
      #else
      #  redirect_to :back, :alert => "The dataset #{@dataset.name} could not be deleted."
    end
  end

  def update
    if @ands_publishable.update_attributes(params[:ands_publishable])
      @ands_publishable.reload
      render :specify_related_info
    else
      @redirect_path = nil
    end
  end

  def approve

    AndsPublishable.transaction do
      begin
        AndsHandle.assign_handle(@ands_publishable)
        @ands_publishable.approve
        @successful = true
      rescue
        @successful = false

      end
    end

    if @successful
      Notifier.notify_user_of_approved_publishable_request(@ands_publishable).deliver
      redirect_to(ands_publishable_requests_users_path, :notice => "The RDA publishable has been approved.")
    else
      redirect_to(ands_publishable_requests_users_path, :alert => "#{@ands_publishable.errors[:base][0]}")

    end
  end

  def reject
    reason = params[:reason]
    if reason.blank?
      @redirect_path = nil
    else
      @ands_publishable.reject
      Notifier.notify_user_of_rejected_publishable_request(@ands_publishable, reason).deliver
      flash[:notice] = "The RDA publishable was rejected."
      @redirect_path = ands_publishable_requests_users_path

    end
  end

  def reject_reason
  end

  def list_subject_keywords
    respond_to do |f|
      f.json do
        q = params[:term]
        if q.blank?
          render :json => nil and return
        end
        potential_codes = AndsSubject.potential_codes(q)
        codes = Array.new

        if AndsSubject.new(:keyword => q).valid?
          codes << Hash[:id => "new_#{q}", :label => "#{q} (create new)", :value => "#{q}"]

        end

        potential_codes.collect do |u|
          codes << Hash[:id => u.id, :label => "#{u.keyword}", :value => "#{u.keyword}"]
        end
        render :json => codes
      end
    end
  end

  def list_seo_codes
    respond_to do |f|
      f.json do
        q = params[:term]
        if q.blank?
          render :json => nil and return
        end
        potential_codes = SeoCode.potential_codes(q)
        codes = Array.new
        potential_codes.collect do |u|
          codes << Hash[:id => u.id, :label => "#{u.code} - #{u.name}", :value => "#{u.name}"]
        end
        render :json => codes
      end
    end
  end

  def list_for_codes
    respond_to do |f|
      f.json do
        render :json => ForCode.generate_ac_options(params[:term])
      end
    end
  end

  def list_ands_parties
    respond_to do |f|
      f.json do
        q = params[:term]
        if q.blank?
          render :json => nil and return
        end
        potential_members = AndsParty.potential_members(q)
        parties = Array.new
        potential_members.collect do |u|
          label = u.display_label
          parties << Hash[:id => u.key, :label => label, :value => label]
        end
        render :json => parties
      end
    end
  end

  private

  def set_party_form_variables
    @instruments = @ands_publishable.project.get_instruments
    @conditional_services = AndsPublishable::CONDITIONAL_HANDLES.clone
    @mandatory_services = AndsPublishable::MANDATORY_HANDLES.clone
    @activity = @ands_publishable.project.activity
    @conditional_services.delete('ELN') unless @ands_publishable.project.has_eln_export?
    @conditional_services.delete('MemRE') unless @ands_publishable.project.has_memre_export?

    # unsw and acdata will not be defined if it's the first time visiting the party form
    if @ands_publishable.ands_related_objects.present?
      @checked_handles = @ands_publishable.ands_related_objects.collect(&:handle)
    else
      @checked_handles = @instruments.collect(&:handle) + @mandatory_services.values + @conditional_services.values
      @checked_handles << @activity.handle if @activity
    end

  end

end

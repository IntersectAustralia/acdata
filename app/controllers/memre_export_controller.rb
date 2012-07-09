class MemreExportController < ApplicationController

  before_filter :authenticate_user!
  before_filter :projects_and_memberships, :except => [:download]

  load_and_authorize_resource :dataset
  load_and_authorize_resource :memre_export, :except => [:new, :create]
  respond_to :js, :only => [:new, :edit, :create, :update]

  def new
    authorize! :read, @dataset
    @memre_export = MemreExport.new
  end

  def edit
  end

  def create
    authorize! :read, @dataset

    keys = params[:characterised_by]

    params[:memre_export][:characterised_by_ids] = AndsParty.find_all_by_key(keys).collect(&:id) if keys
    @memre_export = @dataset.build_memre_export(params[:memre_export])
    @saved = @memre_export.save
    @memre_export.publish
  end

  def update
    keys = params[:characterised_by]
    params[:memre_export][:characterised_by_ids] = AndsParty.find_all_by_key(keys).collect(&:id) if keys
    @memre_export.property_details.clear
    @saved = @memre_export.update_attributes(params[:memre_export])
    @memre_export.publish
  end

end

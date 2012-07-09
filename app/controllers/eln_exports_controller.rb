class ElnExportsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :projects_and_memberships, :except => [:download]

  load_and_authorize_resource :dataset
  load_and_authorize_resource :eln_export, :except => [:new, :create ]
  respond_to :js, :only => [ :new, :edit, :create, :update ]

  def new
    authorize! :read, @dataset
    @eln_export = @dataset.eln_exports.new
    set_defaults(@eln_export, @dataset)
    @blogs = current_user.eln_blogs
  end

  def edit
    @blogs = current_user.eln_blogs
  end

  def create
    authorize! :read, @dataset
    if params[:eln_export]
      params[:eln_export][:user] = current_user
      @eln_export = @dataset.eln_exports.new(params[:eln_export])
      blog_poster = ELNBlogPost.new(APP_CONFIG['eln_url'], APP_CONFIG['eln_uid'])
      @saved = false
      begin
        if @eln_export.valid?
          file_ids, file_links = blog_poster.add_files(@dataset.attachments)
          logger.debug("ELN Export create: file_ids = #{file_ids}")
          metadata = @eln_export.metadata_as_hash
          post_url = blog_poster.post(
            current_user.login,
            @eln_export.blog_name,
            @eln_export.title,
            @eln_export.section,
            @eln_export.content,
            Time.now,
            metadata,
            file_ids,
            file_links
          )
          @eln_export.post_url = post_url
        end
        @saved = @eln_export.save
      rescue Exception => e
        logger.error("Could not create ELN Blog post: #{e.message}")
        logger.error(e.backtrace.join("\n"))
        @eln_export.errors.add(:base, e.message)
      end
    end
  end

  def update
    ElnExport.transaction do
      @eln_export.update_attributes!(params[:eln_export])
      begin
        blog_poster = ELNBlogPost.new(APP_CONFIG['eln_url'], APP_CONFIG['eln_uid'])
        file_ids, file_links = blog_poster.add_files(@dataset.attachments)
        logger.debug("ELN Export update: file_ids = #{file_ids}")
        metadata = @eln_export.metadata_as_hash
        blog_poster.post(
          current_user.login,
          @eln_export.blog_name,
          @eln_export.title,
          @eln_export.section,
          @eln_export.content,
          Time.now,
          metadata,
          file_ids,
          file_links,
          @eln_export.post_url,
          'Re-exported from ACData'
        )
        @saved = true
      rescue Exception => e
        @saved = false
        logger.error("Could not update ELN Blog post: #{e.message}")
        logger.error(e.backtrace.join("\n"))
        @eln_export.errors.add(:base, e.message)
        raise ActiveRecord::Rollback, e.message
      end
    end
  end

  private

  def set_defaults(eln_export, dataset)
    eln_export.title ||= dataset.name
    eln_export.section ||= 'Results'
    eln_export.content ||= dataset.metadata_values.core.map{|mv| "#{mv.key}: #{mv.value}"}.join("\n")
    if eln_export.eln_export_metadatas.empty?
      eln_export.eln_export_metadatas.build(:key => 'Instrument', :value => dataset.instrument_name)
    end
  end
end

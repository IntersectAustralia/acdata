# encoding: utf-8
# black magic comment required for copyright symbol
# http://stackoverflow.com/questions/3678172/ruby-1-9-invalid-multibyte-char-us-ascii
class AndsPublishable < ActiveRecord::Base
  RDA_FILES_ROOT = APP_CONFIG['rda_files_root']

  MANDATORY_HANDLES = APP_CONFIG['handles']['mandatory']
  CONDITIONAL_HANDLES = APP_CONFIG['handles']['conditional']

  belongs_to :project
  belongs_to :moderator, :class_name => "User"

  has_and_belongs_to_many :ands_subjects
  has_and_belongs_to_many :for_codes
  has_and_belongs_to_many :seo_codes
  has_many :ands_related_infos, :as => :detailable, :dependent => :destroy
  has_many :ands_related_objects, :dependent => :destroy
  has_one :ands_handle, :as => :assignable

  validates_presence_of :collection_name
  validates_presence_of :moderator_id
  validates_presence_of :collection_description
  validates_presence_of :address
  validates_presence_of :access_rights
	validates_presence_of :coverage_start_date, :if => :has_temporal_coverage
  validate :dates_valid

  validates_length_of :collection_name, :maximum => 255
  validates_length_of :access_rights, :maximum => 255
  validates_length_of :research_group, :maximum => 255
  validates_length_of :address, :maximum => 5000
  validates_length_of :collection_description, :maximum => 5000

  attr_accessible :collection_name, :collection_description, :research_group, :moderator_id, :access_rights, :address, :has_temporal_coverage, :coverage_start_date, :coverage_end_date

  def dates_valid
    if has_temporal_coverage and coverage_start_date and coverage_end_date
      errors.add(:base, "From date must be before To date") if coverage_end_date < coverage_start_date
    end
  end

  def handle
    ands_handle.present? ? ands_handle.key : nil
  end

  def approved?
    self.status == 'A'
  end

  def pending_approval?
    self.status == 'S'
  end

  def to_be_submitted?
    self.status == 'U'
  end

  def approve

    begin

      ands_related_objects.assignable.each do |aro|
        handle = AndsHandle.find_by_key(aro.handle)
        handle.assignable.publish unless handle.blank? or handle.assignable.published?
      end

      if !Dir.exist? RDA_FILES_ROOT
        Rails.logger.debug("Creating folder #{RDA_FILES_ROOT}")
        FileUtils.mkdir_p(RDA_FILES_ROOT, :mode => 0755)
      end

      dest_dir = RDA_FILES_ROOT + "/#{Time.now.strftime("%Y%m%d")}"

      if !Dir.exist? dest_dir
        Rails.logger.debug("Creating folder #{dest_dir}")
        FileUtils.mkdir_p(dest_dir, :mode => 0755)
      end

      sanitized_handle = ands_handle.key.gsub(/[^0-9A-Za-z.\-]/, '_')
      file_path = dest_dir + "/#{sanitized_handle}.xml"
      Rails.logger.debug("AndsPublishable id:#{id} saving RIF-CS to rda folder")

      File.open(file_path, 'w') do |f|
        require "builder"
        xml_builder = Builder::XmlMarkup.new(:target => f, :indent => 2)
        self.to_rif_cs(xml_builder)
      end

      self.update_attribute(:status, 'A')
      self.update_attribute(:published, true)

    rescue StandardError => e
      Rails.logger.error("Error occurred in saving xml. Ands Publishable not approved.")
      Rails.logger.error("Error occurred in parsing: #{e.backtrace.join("\n")}")
      errors.add(:base, "Error saving publishable xml. RDA publishable could not be approved.")
      raise ActiveRecord::Rollback
    end
  end

  def reject
    self.status = 'R'
    save!(:validate => false)
  end

  def submit
    self.status = 'S'
    save!
  end

  def rejected?
    self.status == 'R'
  end

  def to_rif_cs (xml)
    xml.instruct!
    xml.registryObjects(:xmlns => "http://ands.org.au/standards/rif-cs/registryObjects",
                        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                        "xsi:schemaLocation" => "http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/1.3/schema/registryObjects.xsd") do
      xml.registryObject :group => "University of New South Wales" do
        if ands_handle.present?
          xml.key ands_handle.key
        else
          xml.key "to be assigned"
        end
        xml.originatingSource "https://www.researchdata.unsw.edu.au"
        xml.collection :type => "dataset" do
          get_publishable_xml(xml)

        end
      end
    end
  end

  def process_related_objects(params)
    ands_related_objects.destroy_all

    services = params[:services] || []
    instruments = params[:instruments] || []
    activity = params[:activity] || []
    unsw_parties = params[:unsw_parties] || {}
    non_unsw_parties = params[:non_unsw_parties] || {}

    services.each do |service|
      ands_related_objects.create(:relation => AndsRelatedObject::PRESENTED,
                                  :handle => service,
                                  :relation_type => AndsRelatedObject::SERVICE)
    end

    instruments.each do |instrument|
      ands_related_objects.create(:relation => AndsRelatedObject::PRODUCED,
                                  :handle => instrument,
                                  :relation_type => AndsRelatedObject::INSTRUMENT)
    end

    ands_related_objects.create(:relation => AndsRelatedObject::OUTPUT,
                                :handle => activity,
                                :relation_type => AndsRelatedObject::ACTIVITY) if activity.present?

    unsw_parties.each do |handle, attr|
      case attr['relation']
        when "hasAssociationWithSupervisor"
          description = "Supervisor"
        when "hasAssociationWithPI"
          description = "Primary Invesigator"
        else
          description = nil

      end

      ands_related_objects.create(:name => attr['name'],
                                  :relation => attr['relation'],
                                  :handle => handle,
                                  :description => description,
                                  :relation_type => AndsRelatedObject::UNSW)
    end

    non_unsw_parties.each do |handle, attr|
      case attr['relation']
        when "hasAssociationWithSupervisor"
          description = "Supervisor"
        when "hasAssociationWithPI"
          description = "Primary Invesigator"
        else
          description = nil

      end
      ands_related_objects.create(:name => attr['name'],
                                  :relation => attr['relation'],
                                  :handle => handle,
                                  :description => description,
                                  :relation_type => AndsRelatedObject::NON_UNSW)

    end
  end

  private

  def get_publishable_xml(xml)
    xml.name :type => "primary" do
      xml.namePart collection_name
    end
    xml.location do
      xml.address do
				xml.physical :type => "postalAddress" do
	        address_parts = address.split("\r\n")
	        address_parts.each do |line|
	          xml.addressPart line, :type => "addressLine"
	        end
	      end
      end
    end

    if has_temporal_coverage?
      xml.coverage do
        xml.temporal do     
					xml.date coverage_end_date ? coverage_end_date.to_time.to_formatted_s(:w3cdtf) : "", :type => "dateTo", :dateFormat => "W3CDTF" unless coverage_end_date.blank?  
					xml.date coverage_start_date ? coverage_start_date.to_time.to_formatted_s(:w3cdtf) : "", :type => "dateFrom", :dateFormat => "W3CDTF" unless coverage_start_date.blank?        
		  	end
      end
    end

    get_party_activity_xml(xml)
    get_subject_xml(xml)

    xml.description collection_description, :type => "full"
    xml.rights do
      xml.rightsStatement "Copyright © University of New South Wales #{updated_at.year}"
      xml.accessRights access_rights
    end

    get_related_info_xml(xml)
  end

  def get_party_activity_xml(xml)
    ands_related_objects.each do |related_object|
      xml.relatedObject do
        xml.key related_object.handle
        if related_object.description
          # currently only those with descriptions are hasAssociationWith
          xml.relation :type => "hasAssociationWith" do
            xml.description related_object.description
          end
        else
          xml.relation :type => related_object.relation
        end

      end
    end
  end

  def get_subject_xml(xml)
    for_codes.each do |for_code|
      xml.subject for_code.code, :type => "anzsrc-for"
    end
    ands_subjects.each do |subject|
      xml.subject subject.keyword, :type => "local"
    end
  end

  def get_related_info_xml(xml)
    ands_related_infos.each do |related_info|
      xml.relatedInfo :type => "publication" do
        xml.identifier related_info.identifier, :type => related_info.info_type
        xml.title related_info.title
      end
    end
  end

end

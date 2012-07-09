class Activity < ActiveRecord::Base
  RDA_FILES_ROOT = APP_CONFIG['rda_files_root']
  belongs_to :project
  belongs_to :rda_grant
  has_and_belongs_to_many :for_codes
  has_one :ands_handle, :as => :assignable

  validates :project_name, :presence => true, :length => {:maximum => 255}, :unless => :is_from_rda?
  validates :initial_year, :length => {:maximum => 255}
  validates :initial_year, :numericality => true, :if => Proc.new { |activity| activity.initial_year.present? }

  validates :duration, :length => {:maximum => 255}
  validates :total_grant_budget, :length => {:maximum => 255}
  validates :funding_sponsor, :presence => true, :length => {:maximum => 255}, :unless => :is_from_rda?
  validates :funding_scheme, :length => {:maximum => 255}
  validates :project_type, :length => {:maximum => 255}
  validates :from_rda, :inclusion => [true, false]
  validates :project_id, :presence => true, :uniqueness => true

  validates :published, :presence => true, :if => :is_from_rda?
  validates_presence_of :rda_grant_id, :if => :is_from_rda?

  def is_from_rda?
    from_rda?
  end

  def handle
    if from_rda?
      rda_grant.key
    else
      ands_handle.present? ? ands_handle.key : nil
    end
  end

  def display_name
    if from_rda?
      rda_grant.primary_name
    else
      project_name
    end
  end

  def publish

    # don't need to publish if activity is from rda
    unless from_rda?

      begin

        unless Dir.exist? RDA_FILES_ROOT
          Rails.logger.debug("Creating folder #{RDA_FILES_ROOT}")
          FileUtils.mkdir_p(RDA_FILES_ROOT, :mode => 0755)
        end

        dest_dir = RDA_FILES_ROOT + "/#{Time.now.strftime("%Y%m%d")}"

        unless Dir.exist? dest_dir
          Rails.logger.debug("Creating folder #{dest_dir}")
          FileUtils.mkdir_p(dest_dir, :mode => 0755)
        end

        sanitized_handle = ands_handle.key.gsub(/[^0-9A-Za-z.\-]/, '_')
        file_path = dest_dir + "/#{sanitized_handle}.xml"
        Rails.logger.debug("Activity id:#{id} saving RIF-CS to rda folder")

        File.open(file_path, 'w') do |f|
          require "builder"
          xml_builder = Builder::XmlMarkup.new(:target => f, :indent => 2)
          self.to_rif_cs(xml_builder)
        end

        self.update_attribute(:published, true)

      rescue StandardError => e
        Rails.logger.error("Error occurred in saving xml. Activity not published.")
        Rails.logger.error("Error occurred in parsing: #{e.backtrace.join("\n")}")
        errors.add(:base, "Error saving instrument xml. Activity not published.")
        raise ActiveRecord::Rollback
      end
    end

  end

  def to_rif_cs (xml)
    xml.instruct!
    xml.registryObjects(:xmlns => "http://ands.org.au/standards/rif-cs/registryObjects",
                        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                        "xsi:schemaLocation" => "http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/1.3/schema/registryObjects.xsd") do
      xml.registryObject :group => "University of New South Wales" do
        xml.key handle
        xml.originatingSource "https://www.researchdata.unsw.edu.au"
        xml.activity :type => "project" do
          get_activity_xml(xml)

        end
      end
    end
  end

  private
  def get_activity_xml(xml)
    xml.identifier handle, :type => "local"
    xml.name :type => "primary" do
      xml.namePart project_name
    end

    notes = ""
    notes << "Initial Year: #{initial_year}\n" if initial_year
    notes << "Duration: #{duration}\n" if duration
    notes << "Total Grant Budget: #{total_grant_budget}\n" if total_grant_budget
    notes << "Funding Sponsor: #{funding_sponsor}\n" if funding_sponsor
    notes << "Funding Scheme: #{funding_scheme}\n" if funding_scheme
    notes << "Project Type: #{project_type}\n" if project_type

    xml.description notes, :type => "notes"
    for_codes.each do |for_code|
      xml.subject for_code.code, :type => "anzsrc-for"
    end
    xml.relatedObject do
      xml.key APP_CONFIG['handles']['mandatory']['UNSW']
      xml.relation :type => "isManagedBy"
    end


  end


end

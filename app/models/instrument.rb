# encoding: utf-8
# Above required for copyright symbol
# http://stackoverflow.com/questions/3678172/ruby-1-9-invalid-multibyte-char-us-ascii
class Instrument < ActiveRecord::Base
  RDA_FILES_ROOT = APP_CONFIG['rda_files_root']
  has_many :datasets
  has_and_belongs_to_many :instrument_file_types
  has_one :instrument_rule, :dependent => :destroy
  has_one :ands_handle, :as => :assignable

  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}, :length => {:maximum => 255}
  validates :instrument_class, :presence => true, :length => {:maximum => 255}
  validates :is_available, :inclusion => {:in => [true, false]}
  validates :published, :inclusion => {:in => [true, false]}
  validates :upload_prompt, :length => {:maximum => 255}

  default_scope order(:instrument_class, :name)

  before_validation :strip_whitespace

  def strip_whitespace
    name.strip! if name
    instrument_class.strip! if instrument_class
  end

  def file_filter
    # File filters should only be applied if all file types have filters.
    if all_filtered?
      @filter_string ||=
          instrument_file_types.map {
              |file_type| file_type.file_filter_list
          }.flatten.uniq.join('; ')
    else
      nil
    end
  end

  def handle
    ands_handle.present? ? ands_handle.key : nil

  end

  def publish

    begin

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
      Rails.logger.debug("Instrument id:#{id} saving RIF-CS to rda folder")

      File.open(file_path, 'w') do |f|
        require "builder"
        xml_builder = Builder::XmlMarkup.new(:target => f, :indent => 2)
        self.to_rif_cs(xml_builder)
      end

      self.update_attribute(:published, true)

    rescue StandardError => e
      Rails.logger.error("Error occurred in saving xml. Instrument not published.")
      Rails.logger.error("Error occurred in parsing: #{e.backtrace.join("\n")}")
      errors.add(:base, "Error saving instrument xml. Instrument not published.")
      raise ActiveRecord::Rollback
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
        xml.service :type => "create" do
          get_service_xml(xml)

        end
      end
    end
  end


  private

  def get_service_xml(xml)
    xml.identifier handle, :type => "local"
    xml.name :type => "primary" do
      xml.namePart name
    end
    xml.location do
      xml.address do
        xml.electronic :type => "email" do
          xml.value email
        end if email.present?
        xml.physical :type => "streetAddress" do
					unless address.blank?          
						xml.addressPart address, :type => "text" if address.present?
					end
					unless voice.blank?
						xml.addressPart voice, :type => "telephoneNumber" if voice.present?
					end          
        end if address.present? or voice.present?
      end
    end if address.present? or voice.present? or email.present?
    xml.relatedObject do
      xml.key APP_CONFIG['handles']['mandatory']['UNSW']
      xml.relation :type => "hasAssociationWith"
    end
    xml.relatedObject do
      xml.key APP_CONFIG['handles']['mandatory']['ACData']
      xml.relation :type => "isPresentedBy"
    end
    xml.description "offline", :type => "deliverymethod"
    xml.description description, :type => "full" if description.present?
  end

  def all_filtered?
    @restricted ||= (instrument_file_types.present? and
        instrument_file_types.to_a.count { |ft| ft.filter.nil? } == 0)
  end

end

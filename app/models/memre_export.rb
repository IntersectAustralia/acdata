class MemreExport < ActiveRecord::Base

  belongs_to :dataset
  has_and_belongs_to_many :characterised_by, :class_name => "AndsParty"

  has_many :property_details, :dependent => :destroy

  validates_presence_of :material_name
  validates_presence_of :material_class_name
  validates_presence_of :form_description
  validates_inclusion_of :material_class_name, :in => %w(Organic Inorganic Biological Hybrid)
  validates_inclusion_of :form_description, :in => ['Flat Sheet', 'Hollow Fibre', 'Tubular', 'Other']

  MEMRE_FILES_ROOT = APP_CONFIG['memre_files_root']

  accepts_nested_attributes_for :property_details, :allow_destroy => true

  def publish
    begin

      unless Dir.exist? MEMRE_FILES_ROOT
        Rails.logger.debug("Creating folder #{MEMRE_FILES_ROOT}")
        FileUtils.mkdir_p(MEMRE_FILES_ROOT, :mode => 0755)
      end

      dest_dir = MEMRE_FILES_ROOT + "/#{Time.now.strftime("%Y%m%d")}"

      unless Dir.exist? dest_dir
        Rails.logger.debug("Creating folder #{dest_dir}")
        FileUtils.mkdir_p(dest_dir, :mode => 0755)
      end

      file_path = dest_dir + "/#{dataset_id} - #{material_name}.xml"
      Rails.logger.debug("MemreExport for Dataset id:#{dataset_id} saving RIF-CS to memre folder")

      File.open(file_path, 'w') do |f|
        require "builder"
        xml_builder = Builder::XmlMarkup.new(:target => f, :indent => 2)
        self.to_xml(xml_builder)
      end

    rescue StandardError => e
      Rails.logger.error("Error occurred in saving xml. Dataset not exported to MemRE.")
      Rails.logger.error("Error occurred in parsing: #{e.backtrace.join("\n")}")
      errors.add(:base, "Error saving memre xml. Dataset not exported to MemRE.")
      raise ActiveRecord::Rollback
    end
  end

  def to_xml (xml)
    xml.instruct!

    xml.tag! "Session" do

      xml.tag! "Formdata" do
        xml.tag! "SubmissionDate", Time.now.strftime("%F %R")

        xml.deposit_type "material_form"

        xml.bd_name material_name
        xml.bd_class_name material_class_name

        xml.bd_source creator
        xml.bd_source_note_characterised_by self.characterised_by.collect(&:display_label).join("\n")

        xml.bd_form_description form_description

        xml.bd_processing_details_name name
        xml.bd_processing_details_notes notes

        property_details.each_with_index do |p, i|

          xml.tag! "PropertyDetails", :id => "PD#{i}" do
            xml.tag! "Name", p.name
            xml.tag! "Type", p.type_of_property
            xml.tag! "Units", p.property_units
          end
          xml.tag! "MeasurementTechniqueDetails", :id => "MT#{i}" do
            xml.tag! "Name", p.measurement_technique
          end

          xml.tag! "DataSourceDetails", :id => "DS#{i}", :type => p.info_type do
            xml.tag! "Name", p.identifier
            xml.tag! "Notes", p.notes
          end

          xml.tag! "PropertyDataDetails", :property => "PD#{i}", :technique => "MT#{i}", :source => "DS#{i}" do
            xml.tag! "Notes", p.description
            xml.tag! "Qualifier", p.qualifier_1
            xml.tag! "Qualifier", p.qualifier_2
            xml.tag! "Qualifier", p.qualifier_3
            xml.tag! "Data", ""
          end

        end


      end

      xml.tag! "Attachments" do

      end

    end
  end

end

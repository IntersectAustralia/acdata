class ElnExportMetadata < ActiveRecord::Base

  belongs_to :eln_export

  validates_length_of :key, :maximum => 255
  validates_length_of :value, :maximum => 255
  validate :key_is_valid_xml_tag_name

  def key_is_valid_xml_tag_name
    disallowed = '!"#$%&\'()*+,/;<=>?@[\]^`{|}~'
    unless key.match(/^[A-Za-z_]+[^#{Regexp.escape(disallowed)}]*$/)
      errors.add(:key, "Keys must start with a letter or underscore and not contain any of: #{disallowed}")
    end
  end
end

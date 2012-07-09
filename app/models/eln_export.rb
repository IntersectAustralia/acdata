class ElnExport < ActiveRecord::Base

  belongs_to :dataset
  belongs_to :user
  has_many :eln_export_metadatas, :dependent => :destroy

  accepts_nested_attributes_for :eln_export_metadatas, :allow_destroy => true, :reject_if => lambda { |a| a[:key].blank? }

  validates_presence_of :dataset
  validates :title, :presence => true
  validates :blog_name, :presence => true
  validates :section, :presence => true
  validates_length_of :content, :maximum => 5000

  def metadata_as_hash
    metadata = {}
    eln_export_metadatas.each do |m|
      metadata[m.key] = m.value
    end
    metadata
  end
end

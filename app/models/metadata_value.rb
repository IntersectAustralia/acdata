class MetadataValue < ActiveRecord::Base

  belongs_to :dataset
  belongs_to :attachment
  validates_presence_of :key

  validates_length_of :key, :maximum => 255
  validates_length_of :value, :maximum => 255

  scope :core, where(:core => true).order(:key)
  # TODO: rename, this overrides a builtin
  scope :extended, where(:core => false).order(:key)
  scope :supplied, where(:supplied => true).order(:key)
  scope :extracted, where(:supplied => false).order(:key)
end

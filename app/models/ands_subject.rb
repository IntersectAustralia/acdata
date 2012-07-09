class AndsSubject < ActiveRecord::Base
  has_and_belongs_to_many :ands_publishables

  validates_presence_of :keyword
  validates_length_of :keyword, :maximum => 255
  validates_uniqueness_of :keyword, :case_sensitive => false

  before_validation :strip_whitespace

  def strip_whitespace
    keyword.strip! if keyword
  end

  def self.potential_codes(name_part)
    escaped_name_part = name_part.strip.gsub('%', '\%').gsub('_', '\_')
    match = escaped_name_part + '%'
    where(:keyword.matches => match)
  end

end

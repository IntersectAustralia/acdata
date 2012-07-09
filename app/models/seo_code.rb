class SeoCode < ActiveRecord::Base
  has_and_belongs_to_many :ands_publishables

  validates_presence_of :name
  validates_presence_of :code

  def self.potential_codes(name_part)
    escaped_name_part = name_part.gsub('%', '\%').gsub('_', '\_')
    match = escaped_name_part + '%'
    where(:name.matches % match | :code.matches % match).select('name, code, id').order(:name, :code)
  end

end

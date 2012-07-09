class ForCode < ActiveRecord::Base
  has_and_belongs_to_many :ands_publishables

  validates_presence_of :name
  validates_presence_of :code

  def self.potential_codes(name_part)
    escaped_name_part = name_part.gsub('%', '\%').gsub('_', '\_')
    match = escaped_name_part + '%'
    where(:name.matches % match | :code.matches % match).select('name, code, id').order(:name, :code)
  end

  def self.generate_ac_options(term)
    if term.blank?
      return nil
    end
    potential_codes = ForCode.potential_codes(term)
    codes = Array.new
    potential_codes.collect do |u|
      codes << Hash[:id => u.id, :label => "#{u.code} - #{u.name}", :value => "#{u.code} - #{u.name}"]
    end
    return codes
  end

end

class AndsParty < ActiveRecord::Base
  has_and_belongs_to_many :memre_exports
  validates :key, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :group, :presence => true

  def self.potential_members(name_part)
    escaped_name_part = name_part.gsub('%', '\%').gsub('_', '\_')
    name_start = escaped_name_part + '%'
    where((:given_name.matches % name_start | :family_name.matches % name_start | :group.matches % name_start)).order(:given_name, :family_name)
  end

  def display_label
    "#{title} #{given_name} #{family_name} (#{self.group})".strip

  end

end

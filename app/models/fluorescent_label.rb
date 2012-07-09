class FluorescentLabel < ActiveRecord::Base
  belongs_to :settings

  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}, :length => {:maximum => 255}

  before_validation :strip_whitespace

  default_scope order(:name)

  def strip_whitespace
    name.strip! if name
  end
end

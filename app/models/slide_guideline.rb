class SlideGuideline < ActiveRecord::Base
  belongs_to :settings
  validates :description, :presence => true
  default_scope order(:id)
end

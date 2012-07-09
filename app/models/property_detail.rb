class PropertyDetail < ActiveRecord::Base

  validates_presence_of :name, :measurement_technique

end

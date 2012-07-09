class MembraneProperty < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :property_type, :presence => true
  validates :property_units, :presence => true
  validates :measurement_techniques, :presence => true
end

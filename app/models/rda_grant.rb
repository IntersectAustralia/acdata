class RdaGrant < ActiveRecord::Base
  validates :key, :presence => true, :uniqueness => true
  validates :group, :presence => true, :inclusion => ["Australian Research Council", "National Health and Medical Research Council"]
  validates :grant_id, :presence => true, :uniqueness => true
  validates :primary_name, :presence => true

end

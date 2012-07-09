class AndsRelatedInfo < ActiveRecord::Base
  belongs_to :detailable, :polymorphic => true

  validates_presence_of :info_type, :identifier, :title#, :detailable_id

  validates_length_of :identifier, :maximum => 255
  validates_length_of :title, :maximum => 255

end

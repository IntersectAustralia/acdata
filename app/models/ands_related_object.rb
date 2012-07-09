class AndsRelatedObject < ActiveRecord::Base
  belongs_to :ands_publishable
  validates_presence_of :handle, :relation_type, :ands_publishable_id, :relation

  NON_UNSW = "AndsParty"
  UNSW = "UnswParty"
  ACTIVITY = "Activity"
  INSTRUMENT = "Instrument"
  SERVICE = "Service"

  PRODUCED = "isProducedBy"
  OUTPUT = "isOutputOf"
  PRESENTED = "isPresentedBy"

  scope :non_unsw, where(:relation_type => NON_UNSW)
  scope :unsw, where(:relation_type => UNSW)
  scope :service, where(:relation_type => SERVICE)
  scope :instrument, where(:relation_type => INSTRUMENT)
  scope :activity, where(:relation_type => ACTIVITY)
  scope :assignable, where((:relation_type >> ACTIVITY) | (:relation_type >> INSTRUMENT))

end

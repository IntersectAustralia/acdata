require 'spec_helper'

describe AndsRelatedObject do
  describe "Validations" do
    it { should validate_presence_of :ands_publishable_id }
    it { should validate_presence_of :relation_type }
    it { should validate_presence_of :relation }
    it { should validate_presence_of :handle }

  end

end

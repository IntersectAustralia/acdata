require 'spec_helper'

describe AndsRelatedInfo do
  describe "Validations" do
    it { should validate_presence_of :identifier }
    it { should validate_presence_of :info_type }
    it { should validate_presence_of :title }

  end


end

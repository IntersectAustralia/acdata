require 'spec_helper'

describe MetadataValue do
  describe "Associations" do
    it { should belong_to(:dataset) }
  end

  describe "Validations" do
    it { should validate_presence_of(:key) }
  end
end

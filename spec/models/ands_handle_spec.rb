require 'spec_helper'

describe AndsHandle do

  before :all do
    Settings.instance.update_attribute(:start_handle_range, "hdl:1959.4/004_300")
    Settings.instance.update_attribute(:end_handle_range, "hdl:1959.4/004_305")

  end

  describe "Associations" do
    it { should belong_to :assignable }

  end

  describe "Validations" do
    it { should validate_presence_of :key }
    it { should validate_presence_of :assignable_id }

    it "should prevent duplicate assignments" do
      handle = AndsHandle.assign_handle(Factory(:instrument))
      handle.key.should eq("hdl:1959.4/004_300")

      handle = AndsHandle.assign_handle(Factory(:instrument))
      handle.key.should eq("hdl:1959.4/004_301")

      Settings.instance.update_attribute(:start_handle_range, "hdl:1959.4/004_304")
      Settings.instance.update_attribute(:end_handle_range, "hdl:1959.4/004_305")

      handle = AndsHandle.assign_handle(Factory(:instrument))
      handle.key.should eq("hdl:1959.4/004_304")

      handle = AndsHandle.assign_handle(Factory(:instrument))
      handle.key.should eq("hdl:1959.4/004_305")

      instrument = Factory(:instrument)
      lambda { AndsHandle.assign_handle(instrument) }.should raise_error

      Settings.instance.update_attribute(:start_handle_range, "hdl:1959.4/004_300")
      Settings.instance.update_attribute(:end_handle_range, "")

      handle = AndsHandle.assign_handle(Factory(:instrument))
      handle.key.should eq("hdl:1959.4/004_302")

      handle = AndsHandle.assign_handle(Factory(:instrument))
      handle.key.should eq("hdl:1959.4/004_303")

      handle = AndsHandle.assign_handle(Factory(:instrument))
      handle.key.should eq("hdl:1959.4/004_306")

    end

  end

end

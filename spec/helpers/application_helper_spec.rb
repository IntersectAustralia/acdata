require 'spec_helper'

describe ApplicationHelper do

  describe "Split list in two" do
    it "should split a list exactly in half when even number of items" do
      helper.split_list([1, 2, 3, 4, 5, 6]).should eq([[1, 2, 3], [4, 5, 6]])
    end

    it "should put the extra item in the first list when an odd number of items" do
      helper.split_list([1, 2, 3, 4, 5]).should eq([[1, 2, 3], [4, 5]])
    end

    it "should handle a list with 1 item" do
      helper.split_list([1]).should eq([[1], []])
    end

    it "should handle a list with 0 items" do
      helper.split_list([]).should eq([[], []])
    end
  end

end

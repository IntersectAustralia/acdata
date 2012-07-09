require 'spec_helper'

describe ProjectsHelper do

  describe "Check if a project has samples" do
    let(:project) { Factory(:project) }

    it "should return false if there are no samples within the project" do
      helper.has_samples?(project).should eq(false)
    end
    
    it "should return false if there is an experiment in the project but no samples" do
      experiment = Factory(:experiment, :project => project)
      helper.has_samples?(project).should eq(false) 
    end

    it "should return true if there is one sample at the project level" do
      Factory(:sample, :samplable => project, :name => "Sample 1")
      helper.has_samples?(project).should eq(true)
    end 

    it "should return true if there is one sample at the experiment level" do
      experiment = Factory(:experiment, :project => project)
      Factory(:sample, :samplable => experiment, :name => "Sample 2")
      helper.has_samples?(project).should eq(true)
    end

    it "should return true if there are many samples attached at various levels" do
      experiment = Factory(:experiment)
      Factory(:sample, :samplable => experiment, :name => "Sample 2")
      Factory(:sample, :samplable => project, :name => "Sample 1")
      helper.has_samples?(project).should eq(true)
    end
  end

  describe "Check if a resource has attachments" do
    before :each do
      @project = Factory(:project)
      @experiment = Factory(:experiment, :project => @project)
      @sample_proj = Factory(:sample, :samplable => @project)
      @sample_exp = Factory(:sample, :samplable => @experiment)
      @dataset_sample_proj = Factory(:dataset, :sample => @sample_proj)
      @dataset_sample_exp = Factory(:dataset, :sample => @sample_exp)
      @att_dataset_sp = Factory(:attachment, :dataset => @dataset_sample_proj)
      @att_dataset_se = Factory(:attachment, :dataset => @dataset_sample_exp)
    end

    it "should return true for projects that contain attachments" do
      helper.has_attachments?(@project).should be_true
    end

    it "should return true for experiments that contain attachments" do
      helper.has_attachments?(@experiment).should be_true
    end

  end
end


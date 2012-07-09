require 'spec_helper'

describe Sample do
  it { should belong_to(:samplable) }

  describe "Validations" do
    it { should validate_presence_of(:name) }

    it "should accept a normal entry" do
      @test1 = Factory.build(:sample)
      @test1.should be_valid
    end

    it "should reject name of length 256" do
      @test1 = Factory.build(:sample, :name => "b"*256)
      @test1.should_not be_valid
    end

    it "should accept name of length 255" do
      @test1 = Factory.build(:sample, :name => "b"*255)
      @test1.should be_valid
    end

    it "should reject description of length 5001" do
      @test1 = Factory.build(:sample, :description => "b"*5001)
      @test1.should_not be_valid
    end

    it "should accept description of length 5000" do
      @test1 = Factory.build(:sample, :description => "b"*5000)
      @test1.should be_valid
    end

    it "should accept a sample belonging to a project" do
      @test1 = Factory.build(:sample, :samplable_id => 1, :samplable_type => "Project")
      @test1.should be_valid
    end

    it "should accept a sample belonging to an experiment" do
      @test1 = Factory.build(:sample, :samplable_id => 1, :samplable_type => "Experiment")
      @test1.should be_valid
    end

    it "should reject a sample with only a parent id, without a type" do
      @test1 = Factory.build(:sample, :samplable_id => 1, :samplable_type => nil)
      @test1.should_not be_valid
    end

    it "should reject a sample with only a type, without a parent id" do
      @test1 = Factory.build(:sample, :samplable_id => nil, :samplable_type => "Experiment")
      @test1.should_not be_valid
      @test2 = Factory.build(:sample, :samplable_id => nil, :samplable_type => "Project")
      @test2.should_not be_valid
    end

    it "should reject a sample with neither an parent id or type" do
      @test1 = Factory.build(:sample, :samplable_id => nil, :samplable_type => nil)
      @test1.should_not be_valid
    end

  end

  describe "Output for the API" do
    it "should return a basic object representing the sample" do
      sample = Factory(:sample, :name => "Sample A")
      result = sample.summary_for_api
      result.should have_key(:id)
      result.should have_key(:name)
      result.should have_key(:datasets)
      result[:id].should eq(sample.id)
      result[:name].should eq(sample.name)
      result[:datasets].should be_an_instance_of(Array)
    end
  end
  
  describe "Moving samples around " do
    it "should not update sample parent if move is unsuccessful" do

      project1 = Factory(:project)
      project2 = Factory(:project)
      
      experiment1 = Factory(:experiment)
      experiment2 = Factory(:experiment)

      sample1 = Factory(:sample, :samplable => project1)
      sample2 = Factory(:sample, :samplable => experiment1)

      FileUtils.mkdir_p(sample1.sample_path)

      #project -> project
      FileUtils.stub(:mv) { raise StandardError }

      Sample.transaction do
        src = sample1.sample_path
        sample1.update_attributes(:samplable => project2)
        lambda { Sample.move_sample(sample1, src) }.should raise(ActiveRecord::Rollback)
        sample1.errors[:base].should include("There was an error in moving the sample. Please contact an administrator")

      end

      Sample.find(sample1.id).samplable.should eq(project1)

      # project -> experiment
      FileUtils.stub(:mv){ raise StandardError }

      Sample.transaction do
        src = sample1.sample_path
        sample1.update_attributes(:samplable => experiment1)
        lambda { Sample.move_sample(sample1, src) }.should raise(ActiveRecord::Rollback)
        sample1.errors[:base].should include("There was an error in moving the sample. Please contact an administrator")

      end

      Sample.find(sample1.id).samplable.should eq(project1)

      #experiment -> project
      FileUtils.stub(:mv) { raise StandardError }

      Sample.transaction do
        src = sample2.sample_path
        sample2.update_attributes(:samplable => project1)
        lambda { Sample.move_sample(sample2, src) }.should raise(ActiveRecord::Rollback)
        sample2.errors[:base].should include("There was an error in moving the sample. Please contact an administrator")

      end

      Sample.find(sample2.id).samplable.should eq(experiment1)

      # experiment -> experiment
      FileUtils.stub(:mv) { raise StandardError }

      Sample.transaction do
        src = sample2.sample_path
        sample2.update_attributes(:samplable => experiment2)
        lambda { Sample.move_sample(sample2, src) }.should raise(ActiveRecord::Rollback)
        sample2.errors[:base].should include("There was an error in moving the sample. Please contact an administrator")

      end

      Sample.find(sample2.id).samplable.should eq(experiment1)


    end

    it "should update sample parent if project has no files" do

      project1 = Factory(:project)
      project2 = Factory(:project)

      experiment1 = Factory(:experiment)
      experiment2 = Factory(:experiment)

      sample1 = Factory(:sample, :samplable => project1)
      sample2 = Factory(:sample, :samplable => experiment1)

      #project -> project
      FileUtils.stub(:mv) { raise StandardError }

      Sample.transaction do
        src = sample1.sample_path
        sample1.update_attributes(:samplable => project2)
        Sample.move_sample(sample1, src)
        sample1.errors.should be_empty

      end

      Sample.find(sample1.id).samplable.should eq(project2)

      # project -> experiment
      FileUtils.stub(:mv){ raise StandardError }

      Sample.transaction do
        src = sample1.sample_path
        sample1.update_attributes(:samplable => experiment1)
        Sample.move_sample(sample1, src)
        sample1.errors.should be_empty

      end

      Sample.find(sample1.id).samplable.should eq(experiment1)

      #experiment -> project
      FileUtils.stub(:mv) { raise StandardError }

      Sample.transaction do
        src = sample2.sample_path
        sample2.update_attributes(:samplable => project1)
        Sample.move_sample(sample2, src)
        sample2.errors.should be_empty

      end

      Sample.find(sample2.id).samplable.should eq(project1)

      # experiment -> experiment
      FileUtils.stub(:mv) { raise StandardError }

      Sample.transaction do
        src = sample2.sample_path
        sample2.update_attributes(:samplable => experiment2)
        Sample.move_sample(sample2, src)
        sample2.errors.should be_empty

      end

      Sample.find(sample2.id).samplable.should eq(experiment2)


    end

  end

end

require 'spec_helper'

describe Experiment do
  it { should belong_to(:project) }

  describe "Validations" do
    it { should validate_presence_of(:name) }

#    it "should validate uniqueness" do
#      @test1 = Factory(:experiment, :name => "blah")
#      @test2 = Factory.build(:experiment, :name => "   Blah   ")
#      @test2.should_not be_valid
#
#    end
#
#    it "should validate uniqueness by stripping whitespace" do
#      @test1 = Factory(:experiment, :name => "blah")
#      @test2 = Factory.build(:experiment, :name => "   blah   ")
#      @test2.should_not be_valid
#
#    end
#
#    it "should validate case-insensitive uniqueness" do
#      @test1 = Factory(:experiment, :name => "blah")
#      @test2 = Factory.build(:experiment, :name => "Blah")
#      @test2.should_not be_valid
#
#    end

    it "should reject name of length 256" do
      @test1 = Factory.build(:experiment, :name => "b"*256)
      @test1.should_not be_valid

    end

    it "should accept name of length 255" do
      @test1 = Factory.build(:experiment, :name => "b"*255)
      @test1.should be_valid

    end

    it "should reject description of length 5001" do
      @test1 = Factory.build(:experiment, :description => "b"*5001)
      @test1.should_not be_valid

    end

    it "should accept description of length 5000" do
      @test1 = Factory.build(:experiment, :description => "a"*5000)
      @test1.should be_valid

    end

    it "should reject an invalid url based on semantics of the url" do
      @test1 = Factory.build(:experiment, :url => "a"*20)
      @test2 = Factory.build(:experiment, :url => "http://")
      @test3 = Factory.build(:experiment, :url => "x://a")
      @test4a = Factory.build(:experiment, :url => "http://a.com") #valid
      @test4b = Factory.build(:experiment, :url => "http:\\\\a.com") # invalid: http:\\
      @test1.should_not be_valid
      @test2.should_not be_valid
      @test3.should_not be_valid
      @test4a.should be_valid
      @test4b.should_not be_valid
    end
    
    it "should reject valid url of length 2049" do
      @test1 = Factory.build(:experiment, :url => "http://" << "a"*2042)
      @test1.should_not be_valid
    end

    it "should accept a valid url of length 2048" do
      @test1 = Factory.build(:experiment, :url => "http://" << "a"*2041)
      @test1.should be_valid
    end
  end

  describe "Output for the API" do
    it "should return a basic object representing the experiment" do
      experiment = Factory(:experiment, :name => "Exp A")
      result = experiment.summary_for_api
      result.should have_key(:name)
      result.should have_key(:samples)
      result[:name].should eq(experiment.name)
      result[:samples].should be_an_instance_of(Array)
    end

    it "should return a basic object representing the experiment, without samples" do
      experiment = Factory(:experiment, :name => "Exp A")
      result = experiment.summary_for_api(:samples => false)
      result.should_not have_key(:samples)
    end
  end

  describe "Moving experiments between projects" do
    it "should not update project parent if move is unsuccessful" do
      project1 = Factory(:project)
      project2 = Factory(:project)
      experiment = Factory(:experiment, :project => project1)

      FileUtils.mkdir_p(experiment.experiment_path)
      FileUtils.stub(:mv).and_return { raise StandardError }

      Experiment.transaction do
        src = experiment.experiment_path
        experiment.update_attributes(:project => project2)
        lambda { Experiment.move_experiment(experiment, src) }.should raise(ActiveRecord::Rollback)
        experiment.errors[:base].should include("There was an error in moving the experiment. Please contact an administrator")

      end

      Experiment.find(experiment.id).project.should eq(project1)
    end

    it "should update project parent if experiment has no files" do
      project1 = Factory(:project)
      project2 = Factory(:project)
      experiment = Factory(:experiment, :project => project1)

      FileUtils.stub(:mv).and_return { raise StandardError }

      Experiment.transaction do
        src = experiment.experiment_path
        experiment.update_attributes(:project => project2)
        Experiment.move_experiment(experiment, src)
        experiment.errors.should be_empty

      end

      Experiment.find(experiment.id).project.should eq(project2)

    end

  end

end

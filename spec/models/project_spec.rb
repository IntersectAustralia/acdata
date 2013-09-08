require 'spec_helper'

describe Project do
  describe "Associations" do
    it { should belong_to(:user) }
#    it { should have_and_belong_to_many(:members) }
    it { should have_many(:experiments) }
    it { should have_many(:samples) }
    it { should have_one(:ands_publishable) }
  end

  describe "Validations" do
    let(:user1) { Factory(:user, :login => "user1") }
    let(:user2) { Factory(:user, :login => "user2") }

    it { should validate_presence_of(:name) }

    it "should validate uniqueness" do
      test1 = Factory(:project, :name => "blah", :user => user1)
      test2 = Factory.build(:project, :name => "blah", :user => user1)
      test2.should_not be_valid
      test3 = Factory.build(:project, :name => "blah", :user => user2)
      test3.should be_valid
    end

    it "should validate uniqueness by stripping whitespace" do
      test1 = Factory(:project, :name => "blah", :user => user1)
      test2 = Factory.build(:project, :name => "   blah   ", :user => user1)
      test2.should_not be_valid
    end

    it "should validate case-insensitive uniqueness" do
      test1 = Factory(:project, :name => "blah", :user => user1)
      test2 = Factory.build(:project, :name => "Blah", :user => user1)
      test2.should_not be_valid
    end

    it "should reject name of length 256" do
      test1 = Factory.build(:project, :name => "b"*256)
      test1.should_not be_valid
    end

    it "should accept name of length 255" do
      test1 = Factory.build(:project, :name => "b"*255)
      test1.should be_valid
    end

    it "should reject description of length 5001" do
      test1 = Factory.build(:project, :description => "b"*5001)
      test1.should_not be_valid
    end

    it "should accept description of length 5000" do
      test1 = Factory.build(:project, :description => "b"*5000)
      test1.should be_valid
    end

    it "should reject an invalid url based on semantics of the url" do
      test1 = Factory.build(:project, :url => "a"*20)
      test2 = Factory.build(:project, :url => "http://")
      test3 = Factory.build(:project, :url => "x://a")
      test4a = Factory.build(:project, :url => "http://a.com") #valid
      test4b = Factory.build(:project, :url => "http:\\\\a.com") # invalid: http:\\
      test1.should_not be_valid
      test2.should_not be_valid
      test3.should_not be_valid
      test4a.should be_valid
      test4b.should_not be_valid
    end

    it "should reject valid url of length 2049" do
      test1 = Factory.build(:project, :url => "http://" << "a"*2042)
      test1.should_not be_valid
    end

    it "should accept a valid url of length 2048" do
      test1 = Factory.build(:project, :url => "http://" << "a"*2041)
      test1.should be_valid
    end
  end

  describe "Project Owner" do
    it "should indicate the user is the owner of the project" do
      user1 = Factory(:user)
      project = Factory(:project, :user => user1, :members => [])
      project.owner?(user1).should be_true
    end
    it "should indicate the user is not the owner of the project" do
      user1 = Factory(:user)
      project = Factory(:project, :members => [])
      project.owner?(user1).should_not be_true
    end

    describe "Change" do

      before(:each) do
        @user1 = Factory(:user)
        @user2 = Factory(:user)
        @project = Factory(:project, :user => @user1, :members => [@user2])
      end

      it "new owner is owner" do
        @project.change_owner(@user2)
        @project.owner?(@user2).should be_true
      end

      it "new owner is no longer member" do
        @project.change_owner(@user2)
        @project.members.should_not include(@user2)
      end

      it "old owner is no longer owner" do
        @project.change_owner(@user2)
        @project.owner?(@user1).should_not be_true
      end

      it "old owner becomes a collaborator" do
        @project.change_owner(@user2)
        @project.collaborators.should include(@user1)
      end
    end
  end

  describe "Project Members" do
    it "should list project members" do
      user1 = Factory(:user)
      members = [Factory(:user), Factory(:user)]
      project = Factory(:project, :user => user1, :members => members)
      project.members.should == members
    end
  end

  describe "Can remove method" do
    let(:user1) { Factory(:user, :login => "user1") }
    let(:user2) { Factory(:user, :login => "user2") }
    let(:user3) { Factory(:user, :login => "user3") }

    it "should return true if the user can remove themself" do
      project = Factory(:project, :name => "Project A", :user => user1, :members => [user2, user3])
      project.can_remove?(user2).should eq(true)
      project.can_remove?(user3).should eq(true)
    end

    it "should return false if the user cannot remove themself" do
      project = Factory(:project, :name => "Project A", :user => user1, :members => [user2, user3])
      project.can_remove?(user1).should eq(false)
    end
  end

  describe "Output for the API" do
    let(:user1) { Factory(:user, :login => "user1") }

    it "should return a basic object representing the project" do
      project = Factory(:project, :name => "Project A", :user => user1)
      result = project.summary_for_api
      result.should have_key(:name)
      result.should have_key(:experiments)
      result.should have_key(:samples)
      result[:name].should eq(project.name)
      result[:experiments].should be_an_instance_of(Array)
      result[:samples].should be_an_instance_of(Array)
    end

    it "should return a basic object representing the project, without samples" do
      project = Factory(:project, :name => "Project A", :user => user1)
      result = project.summary_for_api(:samples => false)
      result.should_not have_key(:samples)
    end
  end

  describe "publishable methods for project" do
    let(:user1) { Factory(:user, :login => "user1") }
    let(:instrument1) {
      Factory(:instrument,
              :instrument_class => "NMR",
              :instrument_file_types => []
      )
    }
    let(:instrument2) {
      Factory(:instrument,
              :instrument_class => "Raman Spectrometers",
              :name => "Renishaw",
              :instrument_file_types => [
                  Factory(:instrument_file_type, :name => 'File 1', :filter => '1'),
                  Factory(:instrument_file_type, :name => 'File 2', :filter => '2')
              ]
      )
    }
    it "should return no instruments if there are no datasets" do
      project = Factory(:project, :name => "Project A", :user => user1)
      project.get_instruments.count.should == 0
    end

    it "should return correct instruments" do
      project = Factory(:project, :name => "Project A", :user => user1)
      experiment = Factory(:experiment, :project => project)

      sample1 = Factory(:sample, :samplable_id => project.id, :samplable_type => "Project")

      sample2 = Factory(:sample, :samplable_id => experiment.id, :samplable_type => "Experiment")

      Factory(:dataset, :instrument => instrument1, :sample => sample1)
      Factory(:dataset, :instrument => instrument2, :sample => sample1)
      Factory(:dataset, :instrument => instrument2, :sample => sample1)
      Factory(:dataset, :instrument => instrument2, :sample => sample2)

      project.get_instruments.count.should == 2

    end

    it "should detect when project contains a dataset that has been exported" do
      project = Factory(:project, :name => "Project A", :user => user1)
      experiment = Factory(:experiment, :project => project)

      sample1 = Factory(:sample, :samplable_id => project.id, :samplable_type => "Project")

      sample2 = Factory(:sample, :samplable_id => experiment.id, :samplable_type => "Experiment")

      dataset1 = Factory(:dataset, :instrument => instrument1, :sample => sample1)
      Factory(:dataset, :instrument => instrument2, :sample => sample1)
      Factory(:dataset, :instrument => instrument2, :sample => sample1)
      Factory(:dataset, :instrument => instrument2, :sample => sample2)

      Factory(:eln_export, :title => "title", :blog_name => "blog name", :section => "section", :dataset => dataset1)

      project.has_eln_export?.should eq(true)

    end

    it "should detect when project does not contains a dataset that has been exported" do
      project = Factory(:project, :name => "Project A", :user => user1)

      project.has_eln_export?.should eq(false)

    end

    it "should detect when project does not contains a dataset that has been exported" do
      project = Factory(:project, :name => "Project A", :user => user1)
      experiment = Factory(:experiment, :project => project)

      sample1 = Factory(:sample, :samplable_id => project.id, :samplable_type => "Project")

      sample2 = Factory(:sample, :samplable_id => experiment.id, :samplable_type => "Experiment")

      dataset1 = Factory(:dataset, :instrument => instrument1, :sample => sample1)
      Factory(:dataset, :instrument => instrument2, :sample => sample1)
      Factory(:dataset, :instrument => instrument2, :sample => sample1)
      Factory(:dataset, :instrument => instrument2, :sample => sample2)

      project.has_eln_export?.should eq(false)

    end
  end

end

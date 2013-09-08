require 'spec_helper'

describe User do
  describe "Associations" do
    it { should belong_to(:role) }
  end

  describe "Validations" do
    it "should have unique nmr usernames" do
      u1 = Factory(:user, :nmr_username => "asd")
      u2 = User.new(:nmr_username => "asd")
      u2.should_not be_valid
      u2.should have(1).error_on(:nmr_username)

    end
    it "should restrict length of supervisor details" do
      u1 = User.new(:supervisor_email => "blah@blah.com." + "a"*300, :supervisor_name => "a"*300, :is_student => true)
      u1.should_not be_valid
      u1.should have(1).error_on(:supervisor_email)
      u1.should have(1).error_on(:supervisor_name)

    end
  end

  describe "Named Scopes" do
    describe "Users Pending Approval Scope" do
      it "should return users that are unapproved ordered by login" do
        u1 = Factory(:user, :login => "fasdf1", :status => 'U')
        u2 = Factory(:user, :status => 'A')
        u3 = Factory(:user, :status => 'U', :login => "asdf1")
        u2 = Factory(:user, :status => 'R')
        User.pending_approval.should eq([u3, u1])
      end
    end
    describe "Approved Users Scope" do
      it "should return users that are approved ordered by login" do
        u1 = Factory(:user, :status => 'A', :login => "fasdf1")
        u2 = Factory(:user, :status => 'U')
        u3 = Factory(:user, :status => 'A', :login => "asdf1")
        u2 = Factory(:user, :status => 'R')
        User.approved.should eq([u3, u1])
      end
    end
  end

  describe "Approve Access Request" do
    it "should set the status flag to A" do
      user = Factory(:user, :status => 'U')
      user.activate
      user.status.should eq("A")
    end
  end

  describe "Reject Access Request" do
    it "should set the status flag to R" do
      user = Factory(:user, :status => 'U')
      user.reject
      user.status.should eq("R")
    end
  end

  describe "Status Methods" do
    context "Active" do
      it "should be active" do
        user = Factory(:user, :status => 'A')
        user.approved?.should be_true
      end
      it "should not be pending approval" do
        user = Factory(:user, :status => 'A')
        user.pending_approval?.should be_false
      end
    end

    context "Unapproved" do
      it "should not be active" do
        user = Factory(:user, :status => 'U')
        user.approved?.should be_false
      end
      it "should be pending approval" do
        user = Factory(:user, :status => 'U')
        user.pending_approval?.should be_true
      end
    end

    context "Rejected" do
      it "should not be active" do
        user = Factory(:user, :status => 'R')
        user.approved?.should be_false
      end
      it "should not be pending approval" do
        user = Factory(:user, :status => 'R')
        user.pending_approval?.should be_false
      end
    end
  end

  describe "Is superuser method" do
    it "should return true if the specified user is a superuser" do
      user = Factory(:user, :password => 'Pass.123')
      user.role = Factory(:role, :name => 'Superuser')
      user.is_superuser?.should be_true
    end

    it "should return false if the specified user is not a superuser" do
      user = Factory(:user, :password => "Pass.123")
      user.role = Factory(:role, :name => 'Researcher')
      user.is_superuser?.should be_false
    end
  end

  describe "Find the number of superusers method" do
    it "should return true if there are at least 2 superusers" do
      super_role = Factory(:role, :name => 'Superuser')
      user_1 = Factory(:user, :role => super_role, :status => 'A', :email => 'user1@example.com.au')
      user_2 = Factory(:user, :role => super_role, :status => 'A', :email => 'user2@example.com.au')
      user_3 = Factory(:user, :role => super_role, :status => 'A', :email => 'user3@example.com.au')
      user_1.check_number_of_superusers(1, 1).should eq(true)
    end

    it "should return false if there is only 1 superuser" do
      super_role = Factory(:role, :name => 'Superuser')
      user_1 = Factory(:user, :role => super_role, :status => 'A', :email => 'user1@example.com.au')
      user_1.check_number_of_superusers(1, 1).should eq(false)
    end

    it "should return true if the logged in user does not match the user record being modified" do
      super_role = Factory(:role, :name => 'Superuser')
      research_role = Factory(:role, :name => 'Researcher')
      user_1 = Factory(:user, :role => super_role, :status => 'A', :email => 'user1@example.com.au')
      user_2 = Factory(:user, :role => research_role, :status => 'A', :email => 'user2@example.com.au')
      user_1.check_number_of_superusers(1, 2).should eq(true)
    end
  end

  describe "User permissions methods" do
    let(:researcher_role) { Factory(:role, :name => 'Researcher') }
    let(:superuser) { Factory(:user, :role => Factory(:role, :name => 'Superuser')) }
    let(:user1) { Factory(:user, :role => researcher_role) }
    let(:user2) { Factory(:user, :role => researcher_role) }
    let(:project1) { Factory(:project, :id => '1', :name => 'project 1', :user => superuser) }
    let(:project2) { Factory(:project, :id => '2', :name => 'project 2', :user => superuser) }
    let(:project3) { Factory(:project, :id => '3', :name => 'project 3', :user => superuser) }

    describe "can_read_projects method" do
      it "should return an array of project ids the user can read" do
        project1.members << user1
        project2.members << user1
        project3.members << user1
        project3.members << user2
        user1.can_read_projects.should =~ [1, 2, 3]
        user2.can_read_projects.should eq([3])
      end

      it "should return an empty array if the user cannot read any projects" do
        project1.members << user1
        project2.members << user1
        user2.can_read_projects.should eq([])
      end
    end

    describe "can_manage_projects method" do
      it "should return an array of project ids the user can manage" do
        project_1 = Factory(:project, :id => '1', :name => 'project 1', :user => user1)
        project_3 = Factory(:project, :id => '3', :name => 'project 3', :user => user1)
        project2.members << user1
        user1.can_manage_projects.should eq([1, 3])
      end

      it "should return an empty array if the user cannot manage any projects" do
        project2.members << user1
        user1.can_manage_projects.should eq([])
      end
    end

    describe "can_read_experiments method" do
      it "should return an array of experiment ids the user can read" do
        experiment1 = Factory(:experiment, :id => '1', :project => project1)
        experiment2 = Factory(:experiment, :id => '2', :project => project2)
        project1.members << user1
        project2.members << user1
        user1.can_read_experiments.should eq([1, 2])
      end

      it "should return an empty array if the user cannot read any experiments" do
        project2.members << user2
        user1.can_read_experiments.should eq([])
      end
    end
  end
end

require 'cancan/matchers'
require 'spec_helper'

describe Ability do 

  let(:research_role) { Factory(:role, :name => 'Researcher') }
  let(:researcher) { Factory(:user, :login => 'ada', :role => research_role) }
  let(:researcher2) { Factory(:user, :login => 'brian', :role => research_role) }
  let(:superuser) { Factory(:user, :login => 'sean', :role => Factory(:role, :name => 'Superuser')) }

  describe "Project permissions" do
    before :each do 
      @researcher_project = Factory(:project, :user => researcher)
      @superuser_project =  Factory(:project, :user => superuser)
    end

    it "should allow a superuser that owns a project to read it" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:read, @superuser_project)
    end

    it "should allow a researcher that owns a project to read it" do
      ability = Ability.new(researcher)
      ability.should be_able_to(:read, @researcher_project)
    end

    it "should allow a superuser that is a member of a project to read it" do
      @researcher_project.members << superuser
      ability = Ability.new(superuser)
      ability.should be_able_to(:read, @researcher_project)    
    end

    it "should allow a researcher that is a member of a project to read it" do
      @superuser_project.members << researcher
      ability = Ability.new(researcher)
      ability.should be_able_to(:read, @superuser_project)
    end

    it "should allow an owner of a project to update it" do
      ability = Ability.new(researcher)
      ability.should be_able_to(:update, @researcher_project)
    end

    it "should not allow a member of a project to update it" do
      @superuser_project.members << researcher
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:update, @superuser_project)
    end

    it "should allow a project member to remove themself from the project" do
      @superuser_project.members << researcher
      ability = Ability.new(researcher)
      ability.should be_able_to(:leave, @superuser_project)
    end

    it "should not allow a project owner to leave their own project" do
      ability = Ability.new(superuser)
      ability.should_not be_able_to(:leave, @superuser_project)
    end
    
    it "should allow a project owner to download project data" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:download, @superuser_project)  
    end

    it "should allow a project member to download project data" do
      @superuser_project.members << researcher
      ability = Ability.new(researcher)
      ability.should be_able_to(:download, @superuser_project)
    end

    it "should allow a project owner to destroy the project" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:destroy, @superuser_project)
    end

    it "should not allow a project member to destroy the project" do
      @superuser_project.members << researcher
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:destroy, @superuser_project)
    end

    it "should allow a project owner to see sample selection screen when adding a dataset from the project home page" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:sample_select, @superuser_project)
    end

    it "should not allow a project member to see sample selection screen when adding a dataset from the project home page" do
      @superuser_project.members << researcher
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:sample_select, @superuser_project)
    end

    it "should allow a project owner to save the sample selection made as part of adding a dataset" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:save_sample_select, @superuser_project)
    end

    it "should not allow a project member to save the sample selection made as part of adding a dataset" do
      @superuser_project.members << researcher
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:save_sample_select, @superuser_project)
    end 
  end

  describe "Experiment permissions" do
    it "should allow a superuser that owns the project to view the experiment" do
      experiment = Factory(:experiment, :project => Factory(:project, :user => superuser))
      ability = Ability.new(superuser)
      ability.should be_able_to(:read, experiment)
    end

    it "should allow a researcher the owns the project to view the experiment" do
      experiment = Factory(:experiment, :project => Factory(:project, :user => researcher))
      ability = Ability.new(researcher)
      ability.should be_able_to(:read, experiment)
    end

    it "should allow a superuser that is a member to view the experiment" do
      project = Factory(:project, :user => researcher)
      experiment = Factory(:experiment, :project => project)
      project.members << superuser
      ability = Ability.new(superuser)
      ability.should be_able_to(:read, experiment)
    end

    it "should allow a researcher that is a member to view the experiment" do
      project =  Factory(:project, :user => superuser)
      experiment = Factory(:experiment, :project => project)
      project.members << researcher
      ability = Ability.new(researcher)
      ability.should be_able_to(:read, experiment)
    end

    it "should allow a project owner to create an experiment in the project" do
      project = Factory(:project, :user => researcher, :name => 'Number 2')
      ability = Ability.new(researcher)
      ability.should be_able_to(:create, project.experiments.new)
    end

    it "should not allow a project member to create an experiment in the project" do
      project = Factory(:project, :user => researcher, :name => 'Number 2')
      project.members << superuser
      ability = Ability.new(superuser)
      ability.should_not be_able_to(:create, project.experiments.new)
    end

    it "should allow a project owner to update an experiment in the project" do
      experiment = Factory(:experiment, :project => Factory(:project, :user => researcher))
      ability = Ability.new(researcher)
      ability.should be_able_to(:update, experiment)
    end

    it "should not allow a project member to update an experiment in the project" do
      project = Factory(:project, :user => researcher)
      experiment = Factory(:experiment, :project => project)
      project.members << superuser
      ability = Ability.new(superuser)
      ability.should_not be_able_to(:update, experiment)
    end

    it "should allow project members and collaborators to download related documents" do
      project = Factory(:project, :user => researcher)
      experiment = Factory(:experiment, :project => project)
      project.members << superuser
      project.collaborators << researcher2
      ability = Ability.new(superuser)
      ability.should be_able_to(:collect_document, experiment)
      ability = Ability.new(researcher2)
      ability.should be_able_to(:collect_document, experiment)
    end
  end

  describe "Samples perimission" do
  
    before :each do 
      @project = Factory(:project, :user => superuser)
      @experiment = Factory(:experiment, :project => @project)
      @project.members << researcher
      @sample_experiment = Factory(:sample, :samplable => @experiment)
      @sample_project = Factory(:sample, :samplable => @project)
    end

    it "should allow a project owner to create a sample" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:create_sample, @project)
    end 

    it "should not allow a project member to create a sample" do
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:create_sample, @project)
    end

    it "should allow a project owner to read a sample attached to the project" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:read, @sample_project)
    end

    it "should allow a project owner to read a sample attached to an experiment in the project" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:read, @sample_experiment) 
    end

    it "should allow a project member to read a sample attached to the project" do
      ability = Ability.new(researcher)
      ability.should be_able_to(:read, @sample_project)
    end

    it "should allow a project member to read a sample attached to an experiment in the project" do
      ability = Ability.new(researcher)
      ability.should be_able_to(:read, @sample_experiment)
    end

    it "should allow a project member to update the sample attached to the project" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:update, @sample_project)
    end 
 
    it "should allow a project member to update a sample attached to an experiment in the project" do
      ability = Ability.new(superuser)                     
      ability.should be_able_to(:update, @sample_experiment)  
    end

    it "should not allow a project member to update a sample in the project" do
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:update, @sample_project)   
    end

    it "should not allow a project member to update a sample attached to an experiment in the project" do
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:update, @sample_experiment)  
    end

    it "should allow a project owber to destroy a sample attached to the project" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:destroy, @sample_project)
    end
    
    it "should allow a project owner to destroy a sample attached to an experiment in the project" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:destroy, @sample_experiment)
    end

    it "should not allow a project member to destroy a sample attached to the project" do
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:destroy, @sample_project) 
    end

    it "should not allow a project member to destroy a sample attached to an experiment in the project" do
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:destroy, @sample_experiment) 
    end
  end

  describe "Datasets permissions" do
   
    before :each do 
      project = Factory(:project, :user => superuser)
      project.members << researcher
      experiment = Factory(:experiment, :project => project)
      @dataset = Factory(:dataset, :sample => Factory(:sample, :samplable => experiment))
    end

    it "should allow a project owner to read datasets" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:read, @dataset)
    end
    
    it "should allow a project member to read datasets" do
      ability = Ability.new(researcher)
      ability.should be_able_to(:read, @dataset)
    end

    it "should allow a project owner to download dataset data" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:download, @dataset)
    end

    it "should allow a project member to download dataset data" do
      ability = Ability.new(researcher)
      ability.should be_able_to(:download, @dataset)
    end
   
    it "should allow a project owner to update the dataset name" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:update, @dataset)
    end

    it "should not allow a project member to update the dataset name" do
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:update, @dataset)
    end

    it "should allow a project owner to delete the dataset" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:destroy, @dataset)
    end

    it "should not allow a project member to delete the dataset" do
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:destroy, @dataset)
    end

    it "should allow a project owner to view metadata" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:metadata, @dataset)
    end

    it "should allow a project member to view metadata" do
      ability = Ability.new(researcher)
      ability.should be_able_to(:metadata, @dataset)
    end

    it "should allow a project owner to view the dx file data" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:show_display_attachment, @dataset)
    end

    it "should allow a project member to view the dx file data" do
      ability = Ability.new(researcher)
      ability.should be_able_to(:show_display_attachment, @dataset)
    end

    it "should allow a project owner to upload to the dataset" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:upload, @dataset)
    end

    it "should not allow a project member to upload to the dataset" do
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:upload, @dataset)
    end 
  end

  describe "Attachment permissions" do
    before :each do
      @project = Factory(:project, :user => superuser) 
      experiment = Factory(:experiment, :project => @project)
      dataset = Factory(:dataset, :sample => Factory(:sample, :samplable => experiment))
      @attachment = Factory(:attachment,  :dataset => dataset)
    end
    
    it "should allow a project owner to read attachments" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:read, @attachment)  
    end

    it "should allow a project owner to download attachments" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:download, @attachment)
    end

    it "should allow a project owner to delete attachments" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:destroy, @attachment)
    end
 
    it "should allow a project owner to upload attachments" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:upload, @attachment)
    end

    it "should not allow a project member to delete attachments" do
      @project.members << researcher
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:destroy, @attachment)
    end

    it "should not allow a project member to upload attachments" do
      @project.members << researcher
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:upload, @attachment)
    end
  end

  describe "User perimissions" do
    it "should allow superusers to access the admin page" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:admin, superuser)
    end
   
    it "should not allow researcher to access the admin page" do
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:admin, researcher) 
    end
  
    it "should allow superusers to read user data" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:read, superuser) 
    end
    
    it "should not allow reseachers to read user data" do
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:read, researcher)
    end

    it "should allow superusers to process acccess requests" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:access_requests, superuser)
    end

    it "should not allow researchers to process access requests" do
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:access_requests, researcher)
    end

    it "should allow superusers to update a users role" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:update_role, superuser)
    end

    it "should not allow reseachers to update a users role" do
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:update_role, researcher)
    end

    it "should allow superusers to activate and deactivate users" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:activate_deactivate, superuser)
    end

    it "should not allow researchers to activate and deactivate users" do
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:activate_deactivate, researcher)
    end

    it "should allow superusers to approve users" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:approve, superuser)
    end 

    it "should not allow reseachers to approve users" do
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:approve, researcher)
    end

    it "should allow superuser to reject users" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:reject, superuser)
    end
    
    it "should not allow reseachers to reject users" do
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:reject, researcher)
    end

    it "should allow users to be listed on the add project page" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:list, superuser)

      ability = Ability.new(researcher)
      ability.should be_able_to(:list, researcher)
    end
  end

  describe "Instrument permissions" do
    let(:instrument) {Factory(:instrument, :name => 'Ins 1')}

    it "should allow a superuser to read the manage instruments page" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:read, instrument)
    end

    it "should not allow a researcher to read the manage instruments page" do
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:read, instrument)
    end

    it "should allow a superuser to update an instrument" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:update, instrument)
    end

    it "should not all a researcher to update an instrument" do
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:update, instrument)
    end

    it "should allow a superuser to mark an instrument as available" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:mark_available, instrument)
    end

    it  "should allow a superuser to mark an instrument as unavailable" do
      ability = Ability.new(superuser)
      ability.should be_able_to(:mark_unavailable, instrument)
    end

    it "should not allow a researcher to mark an instrument as available" do
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:mark_available, instrument)
    end

    it "should not allow a researcher to mark an instrument as unavailable" do
      ability = Ability.new(researcher)
      ability.should_not be_able_to(:mark_unavailable, instrument)
    end
  end
end

require 'spec_helper'

describe ProjectsController do
  include Devise::TestHelpers

  before(:each) do
    @user = mock_model(User)
    sign_in @user
    @ability = mock(Ability).as_null_object
    Ability.stub(:new).with(@user) { @ability }
  end

  # (Note: Do we have to test this if it's covered in cucumber?)
  # Seems to fail.
  describe "Creating projects" do
    it "assigns the current user as the owner when creating a new project" do
      mock_project = mock_model(Project)
      mock_project.should_receive(:user=).with(@user)
      mock_project.should_receive(:save)
      Project.stub(:new) { mock_project }
      put :create, :project => { :name => "Foo" }, :format => :js
    end
  end

end

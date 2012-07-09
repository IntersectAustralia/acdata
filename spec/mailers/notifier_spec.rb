require "spec_helper"

describe Notifier do

  describe "Email notifications to users should be sent" do
    it "should send mail to user after sign up" do
      address = 'user@email.org'
      user = Factory(:user, :status => "U", :email => address)
      email = Notifier.notify_user_of_sent_request(user).deliver

      # check that the email has been queued for sending
      ActionMailer::Base.deliveries.empty?.should eq(false)
      email.to.should eq([address])
      email.subject.should eq("ACData - Your access request has been received")
    end

    it "should send mail to user if access request approved" do
      address = 'user@email.org'
      user = Factory(:user, :status => "A", :email => address)
      email = Notifier.notify_user_of_approved_request(user).deliver

      # check that the email has been queued for sending
      ActionMailer::Base.deliveries.empty?.should eq(false)
      email.to.should eq([address])
      email.subject.should eq("ACData - Your access request has been approved")
    end

    it "should send mail to user if access request denied" do
      address = 'user@email.org'
      user = Factory(:user, :status => "A", :email => address)
      email = Notifier.notify_user_of_rejected_request(user).deliver

      # check that the email has been queued for sending
      ActionMailer::Base.deliveries.empty?.should eq(false)
      email.to.should eq([address])
      email.subject.should eq("ACData - Your access request has been rejected")
    end
  end

  describe "Notification to superusers when new access request created"
  it "should send the right email" do
    address = 'user@email.org'
    user = Factory(:user, :status => "U", :email => address)
    User.should_receive(:get_superuser_emails) { ["super1@example.com.au", "super2@example.com.au"] }
    email = Notifier.notify_superusers_of_access_request(user).deliver

    # check that the email has been queued for sending
    ActionMailer::Base.deliveries.empty?.should eq(false)
    email.subject.should eq("ACData - There has been a new access request")
    email.to.should eq(["super1@example.com.au", "super2@example.com.au"])
  end

  describe "Notification to selected moderator of RDA publishable when new request created"
  it "should send the right email" do

    address = 'user@email.org'
    user = Factory(:user, :email => address)
    ands_publishable = Factory(:ands_publishable, :moderator_id => user.id)
    email = Notifier.notify_moderator_of_publishable(ands_publishable).deliver

    # check that the email has been queued for sending
    ActionMailer::Base.deliveries.empty?.should eq(false)
    email.subject.should eq("ACData - A new RDA publishable is pending approval")
    email.to.should eq(['user@email.org'])
  end

  describe "Email notifications to slide scanning service should be sent" do

    it "should send mail to supervisor and slide scanning service admin (without ethics approval)" do
      Settings.instance.update_attribute(:slide_scanning_email, "acdata@unsw.edu.au")
      user = Factory(:user, :first_name => "Test", :last_name => "1", :email => "user1@test.com", :is_student => false)

      project = Factory(:project, :name => "Test Project 1", :user_id => user.id)
      params = {:user_id => user.id, :project_id => project.id, :dept_group => "group", :fund_number => "fund 1", :dept_id => "dept id 1", :project_number => "project 1", :approval_not_required => 1, :num_slides => "123", :scanning_type => "Brightfield", :magnification => "20x", :include_algorithms => "No", :fluorescent_label => "Alexa Fluor 350"}
      email = Notifier.send_slide_request_email(params).deliver

      # check that the email has been queued for sending
      ActionMailer::Base.deliveries.empty?.should eq(false)
      email.to.should eq([user.get_supervisor_email, "acdata@unsw.edu.au"])
      email.subject.should eq("ACData - There has been a new slide scanning service request by Test 1")
      email.body.should match("Ethics approval not required.")

    end

    it "should send mail to supervisor and slide scanning service admin (with ethics approval)" do
      Settings.instance.update_attribute(:slide_scanning_email, "acdata@unsw.edu.au")
      user = Factory(:user, :first_name => "Test", :last_name => "1", :email => "user1@test.com", :is_student => false)

      project = Factory(:project, :name => "Test Project 1", :user_id => user.id)
      params = {:user_id => user.id, :project_id => project.id, :dept_group => "group", :fund_number => "fund 1", :dept_id => "dept id 1", :project_number => "project 1", :approval_number => "ethics 1", :num_slides => "123", :scanning_type => "Brightfield", :magnification => "20x", :include_algorithms => "No", :fluorescent_label => "Alexa Fluor 350"}
      email = Notifier.send_slide_request_email(params).deliver

      # check that the email has been queued for sending
      ActionMailer::Base.deliveries.empty?.should eq(false)
      email.to.should eq([user.get_supervisor_email, "acdata@unsw.edu.au"])
      email.subject.should eq("ACData - There has been a new slide scanning service request by Test 1")
      email.body.should match("ethics 1")
    end

    it "should send mail to supervisor and slide scanning service admin" do
      Settings.instance.update_attribute(:slide_scanning_email, "acdata@unsw.edu.au")
      user = Factory(:user, :first_name => "Test", :last_name => "1", :email => "user1@test.com", :is_student => true, :supervisor_name => "Test Supervisor 1", :supervisor_email => "test-supervisor1@test.com")

      project = Factory(:project, :name => "Test Project 1", :user_id => user.id)
      params = {:user_id => user.id, :project_id => project.id, :dept_group => "group", :fund_number => "fund 1", :dept_id => "dept id 1", :project_number => "project 1", :approval_number => "ethics 1", :num_slides => "123", :scanning_type => "Brightfield", :magnification => "20x", :include_algorithms => "No", :fluorescent_label => "Alexa Fluor 350"}
      email = Notifier.send_slide_request_email(params).deliver

      # check that the email has been queued for sending
      ActionMailer::Base.deliveries.empty?.should eq(false)
      email.to.should eq([user.get_supervisor_email, "acdata@unsw.edu.au"])
      email.subject.should eq("ACData - There has been a new slide scanning service request by Test 1")
      email.body.should match("test-supervisor1@test.com")
      email.body.should match("Test Supervisor 1")
    end

    it "should send mail to supervisor and slide scanning service admin" do
      Settings.instance.update_attribute(:slide_scanning_email, "acdata@unsw.edu.au")
      user = Factory(:user, :first_name => "Test", :last_name => "1", :email => "user1@test.com", :is_student => true, :supervisor_name => "Test Supervisor 1", :supervisor_email => "test-supervisor1@test.com")

      project = Factory(:project, :name => "Test Project 1", :user_id => user.id)
      params = {:user_id => user.id, :project_id => project.id, :dept_group => "group", :fund_number => "fund 1", :dept_id => "dept id 1", :project_number => "project 1", :approval_number => "ethics 1", :num_slides => "123", :scanning_type => "Brightfield", :magnification => "20x", :include_algorithms => "No", :fluorescent_label => "Alexa Fluor 350"}
      email = Notifier.notify_user_of_slide_request(params).deliver

      # check that the email has been queued for sending
      ActionMailer::Base.deliveries.empty?.should eq(false)
      email.to.should eq([user.email])
      email.subject.should eq("ACData - Your slide scanning service request has been received")
      email.body.should match("test-supervisor1@test.com")
      email.body.should match("Test Supervisor 1")
    end
  end
end

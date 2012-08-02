require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

module WithinHelpers
  def with_scope(locator)
    locator ? within(*selector_for(locator)) { yield } : yield
  end
end
World(WithinHelpers)

Given /^I have the usual projects$/ do
  step "I have the following projects", table(%{
      | name      | description   | owner |
      | project a | The A Project | user1 |
      | project b | The B Project | user2 |
      | project c | The C Project | user3 |
  })
end

Given /^I have the following projects$/ do |table|
  table.hashes.each do |row|
    owner = User.find_by_login(row[:owner])
    p = Project.create!(:name        => row[:name],
                        :description => row[:description],
                        :user => owner)
  end
end


Given /^"([^"]*)" is a member of "([^"]*)"$/ do |user, project|
  user = User.find_by_login(user)
  project = Project.find_by_name(project)
  project.members << user
end

Then /^"([^"]*)" should have the following members$/ do |project, table|
  project = Project.find_by_name(project)
  table.hashes.each do |row|
    user = User.find_by_login(row[:name])
    project.members.include?(user)
  end
end

Then /^"([^"]*)" should have no members$/ do |project|
  project = Project.find_by_name(project)
  project.members.size.should eq 0
end

Given /^I choose "([^"]*)" from the autocomplete list$/ do |item|
  with_scope("autocomplete options") {
    page.find('a', :text => item).click
  }
end

Given /^I start filling in "([^"]*)" with "([^"]*)"$/ do |field, value|
  fill_in(field, :with => value)
end

Given /^I have the following members for projects$/ do |table|
  table.hashes.each do |row|
    p = Project.find_by_name(row[:name])
    member_logins = row[:members].split(",")
    members = member_logins.collect { |l| User.find_by_login(l) }
    p.update_attribute("members", members)
  end
end

Given /^I have the following collaborators for projects$/ do |table|
  table.hashes.each do |row|
    p = Project.find_by_name(row[:name])
    member_logins = row[:members].split(",")
    members = member_logins.collect { |l| User.find_by_login(l) }
    p.update_attribute("collaborators", members)
  end
end

Then /^I should see "([^"]*)" in the "([^"]*)" list$/ do |project_name, list_name|
  with_scope(list_name) do
    page.should have_content(project_name)
  end
end

Then /^I should not see "([^"]*)" in the "([^"]*)" list$/ do |project_name, list_name|
  with_scope('#' + list_name) do
    page.should_not have_content(project_name)
  end
end

Then /^I should have a project "([^"]*)" for user "([^"]*)"$/ do |project_name, login|
  user = User.find_by_login(login)
  begin
    wait_until do
      Project.where(:user_id => user.id, :name => project_name).size == 1
    end
  rescue Exception => e
    raise "Timed out trying to find project #{project_name}"
  end
end

Then /^user "([^"]*)" should have access to project "([^"]*)"$/ do |login, project_name|
  user = User.find_by_login(login)
  project = Project.find_by_name(project_name)
  project.members.should include(user)
end

Then /^I should see the following autocomplete options:$/ do |table|
  with_scope('autocomplete options') {
    table.raw.each do |row|
      page.should have_content(row[0])
    end
  }
end

Then /^I should see "([^"]*)" in the project list$/ do |text|
  with_scope('project list') do
    page.should have_content(text)
  end
end

Then /^I should not see "([^"]*)" in the project list$/ do |text|
  with_scope('project list') do
    page.should_not have_content(text)
  end
end

Then /^"([^"]*)" should have owner "([^"]*)"$/ do |project_name, login|
  user = User.find_by_login(login)
  project = Project.find_by_name(project_name)
  project.user.should == user
end

Given /^I have attached related document "([^"]*)" to project "([^"]*)"$/ do |doc, proj_name|
  project = Project.find_by_name(proj_name)
  project.should_not be_nil
  file_path = File.join('features', 'samples', doc)
  step "I am on the project page for \"#{proj_name}\""
  step "I follow \"Edit\""
  step "I wait for the wizard"
  step "I attach the file \"#{file_path}\" to \"project_document\""
  step "I press \"Update Project\""
  step "I wait for the wizard"
  step "I should see \"Related Document: #{doc}\""
end

Then /I should have a document "([^"]*)" for project "([^"]*)"/ do |doc, proj_name|
  project = Project.find_by_name(proj_name)
  project.document.should_not be_nil
  path = File.join(project.project_path, 'documents', doc)
  project.document.original_filename.should == doc
  project.document.path.should == path
end

And /^I have assigned a grant "([^"]*)" to project "([^"]*)"$/ do | grant_name, proj_name|
  project = Project.find_by_name(proj_name)
  activity = Factory(:activity, :project => project, :from_rda => false, :project_name => grant_name)
  AndsHandle.assign_handle(activity)

end

And /^I have assigned an rda grant "([^"]*)" of key "([^"]*)" to project "([^"]*)"$/ do | grant_name, key, proj_name|
  project = Project.find_by_name(proj_name)
  rda_grant = Factory(:rda_grant, :primary_name => grant_name, :key=> key, :grant_id => key[/\w+$/] )
  activity = Factory(:activity, :project_name => grant_name, :project => project, :from_rda => true,:rda_grant => rda_grant, :published => true)
  AndsHandle.assign_handle(activity)

end

Then /^the "([^"]*)" section should be blank$/ do |section|
  with_scope(section) do
    input_elems = all(:xpath, "//*[text()='#{section}:']/..")
    content = input_elems.first.text
    content.strip.should == "#{section}:"
  end
end

Then /^I have the usual fluorescent labels$/ do
  config_file = File.expand_path("#{Rails.root}/config/fluorescent_labels.yml", __FILE__)
  config = YAML::load_file(config_file)
  file_set = ENV["RAILS_ENV"] || "development"
  config[file_set]['fluorescent_labels'].each do |name|
    FluorescentLabel.create!(:name => name)
  end
end

Given /^I remove "([^"]*)" from membership of the project$/ do |name|
  u = User.where(login: name).first
  page.find(:css, "li#member_#{u.id} span.remove_button").click
end

Then /^project "([^"]*)" should have (\d+) members$/ do |name, number|
  Project.where(name: name).first.members.size.should == number.to_i
end


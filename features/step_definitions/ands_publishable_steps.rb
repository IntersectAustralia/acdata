#Given /^the published data should have the following contact details$/ do |table|
#  table.hashes.each do |row|
#    p = Project.find_by_name(row[:project])
#    data = p.ands_publishable
#    data.ands_contact.given_name.should eq row[:given_name]
#    data.ands_contact.family_name.should eq row[:family_name]
#    data.ands_contact.email.should eq row[:email]
#  end
#end

Given /^the published data for project "([^"]*)" should have keyword "([^"]*)"$/ do |project, keyword|
  p = Project.find_by_name(project)
  data = p.ands_publishable
  assert data.ands_subjects.include? keyword
end
#
#Given /^I have rights "([^"]*)"$/ do |ar|
#  Factory(:ands_rights, :license_type => ar)
#end

#Then /^I should see the location url for project "([^"]*)"$/ do |project|
#  p = Project.find_by_name(project)
#  page.should have_content("https://acdata/project/#{p.id}")
#end

Given /^I have an ANDS Publishable request "([^"]*)" for project "([^"]*)" with moderator "([^"]*)"$/ do |ands_publishable, project, moderator|
  p = Project.find_by_name(project)
  m = User.find_by_login(moderator)
  Factory(:ands_publishable, :moderator => m, :project => p, :collection_name => ands_publishable, :status => 'S')
end

And /^the publishable data "([^"]*)" is approved$/ do |collection_name|
  publishable = AndsPublishable.find_by_collection_name(collection_name)
  AndsHandle.assign_handle(publishable)
  publishable.approve
end

And /^the publishable data "([^"]*)" is rejected/ do |collection_name|
  publishable = AndsPublishable.find_by_collection_name(collection_name)
  publishable.reject
end

Given /^I fill in the (\d+)[a-z]* field with "([^"]*)"$/ do |i, value|
  input_elems = all(:xpath, ".//input[starts-with(@id, 'user_eln_blogs_attributes_')]")
  input_elems[i.to_i-1].set(value)
end

Then /^the link "([^"]*)" should be disabled$/ do |label|
  find_link(label)['disabled'].should == "disabled"
end

Given /^I have FOR codes$/ do |table|
  table.hashes.each do |hash|

    Factory(:for_code, :name => hash[:name], :code => hash[:code])
  end
end

Given /^I have subject keywords$/ do |table|
  table.hashes.each do |hash|

    Factory(:ands_subject, :keyword => hash[:keyword])
  end
end

Given /^I have ANDS Parties$/ do |table|
  table.hashes.each do |hash|

    Factory(:ands_party, :given_name => hash[:given_name], :family_name => hash[:family_name], :key => hash[:key], :group => hash[:group])
  end
end

And /^the publishable "([^"]*)" should have key "([^"]*)" assigned$/ do |collection_name, key|
  publishable = AndsPublishable.find_by_collection_name(collection_name)
  publishable.ands_handle.key.should eq(key)
end
Given /^the grant "([^"]*)" should have a published xml$/ do |name|
  activity = Activity.find_by_project_name(name)
  sanitized_handle = activity.handle.gsub(/[^0-9A-Za-z.\-]/, '_')
  file_path = "#{APP_CONFIG['rda_files_root']}/#{Time.now.strftime("%Y%m%d")}/#{sanitized_handle}.xml"
  File.exists?(file_path).should eq(true)
end

Given /^the grant "([^"]*)" should not have a published xml$/ do |name|
  activity = Activity.find_by_project_name(name)
  sanitized_handle = activity.handle.gsub(/[^0-9A-Za-z.\-]/, '_')
  file_path = "#{APP_CONFIG['rda_files_root']}/#{Time.now.strftime("%Y%m%d")}/#{sanitized_handle}.xml"
  File.exists?(file_path).should eq(false)
end


Given /^I have RDA grants$/ do |table|
  table.hashes.each do |hash|

    Factory(:rda_grant,
            :primary_name => hash[:primary_name],
            :grant_id => hash[:grant_id],
            :key => hash[:key],
            :group => hash[:group],
            :description => hash[:description])
  end
end

And /^the activity record of project "([^"]*)" should not have an ands handle$/ do |name|
  project = Project.find_by_name(name)
  project.activity.ands_handle.should be_nil
end

And /^the activity record of project "([^"]*)" should have an ands handle$/ do |name|
  project = Project.find_by_name(name)
  project.activity.ands_handle.should_not be_nil
end

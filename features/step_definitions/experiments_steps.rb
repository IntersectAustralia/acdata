Given /^I have the usual experiments$/ do
  step "I have the usual projects"
  step "I have the following experiments", table(%{
      | name | description | project   |
      | exp1 | desc1       | project a |
  })
end

Given /^I have the following experiments$/ do |table|
  table.hashes.each do |row|
    project = Project.find_by_name(row[:project])
    Factory(:experiment, :name => row[:name], :description => row[:description], :project => project)
  end
end

Then /^I should have an experiment "([^"]+)"/ do |name|
  Experiment.find_by_name(name).should_not be_nil
end

Given /^I have attached related document "([^"]*)" to experiment "([^"]*)"$/ do |doc, exp_name|
  exp = Experiment.find_by_name(exp_name)
  file_path = File.join('features', 'samples', doc)
  step  "I am on the experiment page for \"#{exp_name}\""
  step "I follow \"Edit\""
  step "I wait for the wizard"
  step "I attach the file \"#{file_path}\" to \"experiment_document\""
  step "I press \"Update Experiment\""
  step "I wait for the wizard"
  step "I should see \"Related Document: #{doc}\""
end

Then /I should( not|) have a document "([^"]*)" for experiment "([^"]*)"/ do |condition, doc, exp_name|
  doc_expected = condition !~ /not/
  exp = Experiment.find_by_name(exp_name)
  path = File.join(exp.experiment_path, 'documents', doc)
  if doc_expected
    exp.document.should_not be_nil
    exp.document.original_filename.should == doc
    exp.document.path.should == path
  else
    if exp.document.present?
      exp.document.original_filename.should_not == doc
    end
  end
end

Then /^the documents for experiment "([^"]*)" should be moved from "([^"]*)" to "([^"]*)"$/ do |exp_name, src_proj_name, dest_proj_name|
  exp = Experiment.find_by_name(exp_name)
  src_proj = Project.find_by_name(src_proj_name)
  dest_proj = Project.find_by_name(dest_proj_name)
  doc = exp.document.original_filename
  path = File.join(exp.experiment_path, 'documents', doc)
  path.should match /project_#{dest_proj.id}/
  path.should == exp.document.path
  File.exists?(path).should be_true
  old_path = path.gsub(/project_\d+/, "project_#{src_proj.id}")
  File.exists?(old_path).should be_false
  path.should_not == old_path
end

Given /^I attach related document "([^"]*)"$/ do |filename|
  file_path = File.join('features', 'samples', filename)
  step "I attach the file \"#{file_path}\" to \"experiment_document\""
end

Given /^I add a sample "([^"]*)" to "([^"]*)"$/ do |sample_name, experiment_name|
  page.find(:css, selector_for('Add')).click
  step 'I follow "Add Sample"'
  step "I wait for the wizard"
  fill_in('Name', :with => sample_name)
  step 'I press "Create Sample"'
  step 'I wait for the wizard'
end


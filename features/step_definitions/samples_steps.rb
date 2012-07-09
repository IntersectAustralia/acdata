Given /^I have the usual samples$/ do
  step "I have the usual experiments"
  step "I have the following samples", table(%{
      | name | description | experiment |
      | s1   | desc1       | exp1       |
  })
  step "I have the following samples", table(%{
      | name | description | project   |
      | s2   | desc2       | project b |
      | s3   | desc3       | project b |
      | s4   | desc4       | project b |
      | s5   | desc5       | project a |
  })
end

Given /^I have the following samples$/ do |table|
  table.hashes.each do |row|
    if (row[:project])
      project = Project.find_by_name(row[:project])
      Factory(:sample, :name => row[:name], :description => row[:description], :samplable => project)
    elsif (row[:experiment])
      experiment = Experiment.find_by_name(row[:experiment])
      Factory(:sample, :name => row[:name], :description => row[:description], :samplable => experiment)
    end

  end
end

Given /^I have the following samples with defined ids$/ do |table|
  table.hashes.each do |row|
    if (row[:project])
      project = Project.find_by_name(row[:project])
      Factory(:sample, :id => row[:id], :name => row[:name], :description => row[:description], :samplable => project)
    elsif (row[:experiment])
      experiment = Experiment.find_by_name(row[:experiment])
      Factory(:sample, :id => row[:id], :name => row[:name], :description => row[:description], :samplable => experiment)
    end

  end
end

Then /^I should be on the new sample page for experiment "([^"]*)" for project "([^"]*)"$/ do |exp_name, project_name|
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should == path_to(page_name)
  else
    assert_equal path_to(page_name), current_path
  end
end

Then /^I should (|not )have a sample "([^"]*)" under (project|experiment) "([^"]*)"$/ do |negative, sample_name, parent_type, parent_name|

  sample = nil
  parent = parent_type.eql?('project') ? Project.find_by_name(parent_name) : Experiment.find_by_name(parent_name)
  begin
    wait_until do
      sample = parent.samples.find_by_name(sample_name)
      sample != nil
    end
    assert_equal sample.samplable.name, parent_name
  rescue
    raise "Could not find sample #{sample_name}" unless negative.match(/not/)
    sample.should be_nil
  end
end

Then /^I should have a sample "([^"]*)"$/ do |sample_name|
  sample = nil
  begin
    wait_until do
      sample = Sample.find_by_name(sample_name)
      sample != nil
    end
  rescue
    raise "Could not find sample #{sample_name}"
  end
end

=begin
Then /^I should not have a sample "([^"]*)" under project "([^"]*)"$/ do |sample_name, project_name|
  sample = Sample.find_by_name(sample_name)
  assert sample.nil?
end

Then /^I should not have a sample "([^"]*)" under experiment "([^"]*)"$/ do |sample_name, exp_name|
  sample = Sample.find_by_name(sample_name)
  assert sample.nil?
end
=end

Given /^I fill in the usual slide scanning details for "([^"]*)"$/ do |project|
  p = Project.find_by_name(project)
  visit project_path(p)
  click_link('Request Slide Scanning')
  step 'I wait for the wizard'
  click_link('Agree')
  fill_in 'Dept/Group', :with => 'some group'
  fill_in 'Reference Lab', :with => 'some lab'
  fill_in 'Fund Number', :with => '123'
  fill_in 'Dept ID', :with => '456'
  fill_in 'Project Number', :with => '789'
  check 'slide_approval_not_required'
  fill_in 'Number of Slides', :with => '42'
  select('Alexa Fluor 350', :from => 'Fluorescent Label')
end

Then /^I should have a slide scanning request for "([^"]*)" with$/ do |project_name, table|
  msg = ActionMailer::Base.deliveries.first
  table.rows.each do |row|
    msg.body.should have_content row[0]
  end
end

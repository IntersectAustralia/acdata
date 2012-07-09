Given /^I have the following instruments$/ do |table|
  table.hashes.each do |row|
    string = row.delete('instrument_file_types')
    visual_types = row.delete('visual types')
    metadata_types = row.delete('metadata types')
    file_type_names = string.split(/\s*,\s*/) if string
    row.delete('handle')
    instrument = Factory(:instrument, row)
    instrument.instrument_file_types << InstrumentFileType.find_all_by_name(file_type_names)
    instrument.instrument_rule =
        Factory(:instrument_rule,
                :metadata_list => metadata_types,
                :visualisation_list => visual_types)
    instrument.save
    AndsHandle.assign_handle(instrument)
  end
end


Given /^I have the following file types$/ do |table|
  table.hashes.each do |row|
    Factory(:instrument_file_type, row)
  end
end

Given /^the instrument "([^"]*)" should have a published xml$/ do |name|
  instrument = Instrument.find_by_name(name)
  sanitized_handle = instrument.handle.gsub(/[^0-9A-Za-z.\-]/, '_')
  file_path = "#{APP_CONFIG['rda_files_root']}/#{Time.now.strftime("%Y%m%d")}/#{sanitized_handle}.xml"
  File.exists?(file_path).should eq(true)
end

Given /^the instrument "([^"]*)" should not have a published xml$/ do |name|
  instrument = Instrument.find_by_name(name)
  sanitized_handle = instrument.handle.gsub(/[^0-9A-Za-z.\-]/, '_')
  file_path = "#{APP_CONFIG['rda_files_root']}/#{Time.now.strftime("%Y%m%d")}/#{sanitized_handle}.xml"
  File.exists?(file_path).should eq(false)
end

Given /^the instrument "([^"]*)" has been published$/ do |name|
  instrument = Instrument.find_by_name(name)
  instrument.update_attribute(:published, true)
end

Given /^I follow edit for "([^"]*)"$/ do |name|
  instrument = Instrument.find_by_name(name)
  click_link("edit_#{instrument.id}")
end

When /^I mark "([^"]*)" as unavailable$/ do |name|
  instrument = Instrument.find_by_name(name)
  click_link("unavailable_#{instrument.id}")
end

When /^I mark "([^"]*)" as available$/ do |name|
  instrument = Instrument.find_by_name(name)
  click_link("available_#{instrument.id}")
end

When /^I follow view for "([^"]*)"$/ do |name|
  instrument = Instrument.find_by_name(name)
  click_link("view_#{instrument.id}")
end

Then /^I fill in the instrument details$/ do
  fill_in('Name', :with => 'New Instrument')
  select('class 1', :from => 'Instrument class')
end


Then /^instrument "([^"]*)" should have the following file types$/ do |name, table|
  instrument = Instrument.find_by_name(name)
  files = instrument.instrument_file_types.collect { |file| file.name }
  table.hashes.each do |row|
    files.include?(row[:name])
  end
end

Then /^I should have a dataset "([^"]*)" with instrument "([^"]*)"$/ do |dataset_name, instrument_name|
  Dataset.find_by_name(dataset_name).instrument.name.should == instrument_name
end

Then /^I should see only the selected file types under each instrument rule$/ do
  page.has_css?('#instrument_file_types option[@selected="selected"]')
  names_selected = page.all(:css, '#instrument_file_types option').select { |elem| elem.selected? }.map(&:text)
  names_not_selected = page.all(:css, '#instrument_file_types option').map(&:text) - names_selected
  %w{metadata visualisation unique exclusive indelible}.each do |rule|
    within("#instrument_rule_#{rule}") do
      names_selected.each { |name| page.should have_content(name) }
      names_not_selected.each { |name| page.should_not have_content(name) }
    end
  end
end

Then /^I should have an instrument "([^"]*)"$/ do |name|
  Instrument.find_by_name(name).should_not be_nil
end

Then /^I should have an instrument rule for "([^"]*)"$/ do |name|
  instrument = Instrument.find_by_name(name)
  instrument.instrument_rule.should_not be_nil
end

Then /^I should see the values for instrument "([^"]*)"$/ do |name|
  instrument = Instrument.find_by_name(name)

  rejects = %w{id created_at updated_at is_available published}
  instrument.attribute_names.reject { |n| rejects.include?(n) }.each do |name|
    within("#display_#{name}") {
      page.should have_content(instrument.send(name))
    }
  end
end

Then /^I should see that "([^"]*)" is (un)?available$/ do |name, status|
  instrument = Instrument.find_by_name(name)
  if status == 'un'
    page.has_selector?("#available_#{instrument.id}")
  else
    page.has_selector?("#unavailable_#{instrument.id}")
  end
end

Then /^I should see that instrument is (un)?available$/ do |status|
  if status == 'un'
    page.should have_content('Currently Unavailable')
  else
    page.should have_content('Current Available')
  end
end

Then /^I should see the instruments table with$/ do |expected_table|
  got_table = tableish("table#instruments tr", 'td,th')
  expected_table.diff!(got_table, {:surplus_col => false})
end



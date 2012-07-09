Given /^I should see the core metadata for "([^"]+?)"$/ do |dataset_name|
  dataset = Dataset.find_by_name(dataset_name)
  within("#container_page_content") do
    metadata = {}
    dataset.metadata_values.core.each do |mv|
      page.should have_content("#{mv.key}: #{mv.value.gsub("\r","").strip}")
    end
  end
end

Given /^I should see the supplied metadata for "([^"]+?)"$/ do |dataset_name|
  dataset = Dataset.find_by_name(dataset_name)
  within("#container_page_content") do
    metadata = {}
    dataset.supplied_metadata.each do |mv|
      page.should have_content("#{mv.key}: #{mv.value.gsub("\r","").strip}")
    end
  end
end


Given /^I should see the metadata for "([^"]+?)" in the "([^"]+?)"$/ do |dataset_name, selector|
  shown_table = tableish(selector_for(selector), 'td')
  dataset = Dataset.find_by_name(dataset_name)
  metadata = {}
  dataset.metadata_values.each do |mv|
    metadata[mv.key] = mv.value
  end
  shown_table.each do |key, value|
    metadata.should include(key)
    value.strip.should == metadata[key].gsub(/\r|\n/,"").strip
  end
end

Given /^I fill in the (\d+)[a-z]* supplied metadata field with (\d+) characters$/ do |i, value|
  input_elems = all(:xpath, ".//input[starts-with(@id, 'dataset_supplied_metadata_attributes_')]")
  input_elems[i.to_i-1].set("a"*value.to_i)
end

Given /^I fill in the (\d+)[a-z]* supplied metadata field with "([^"]*)"$/ do |i, value|
  input_elems = all(:xpath, ".//input[starts-with(@id, 'dataset_supplied_metadata_attributes_')]")
  input_elems[i.to_i-1].set(value)
end

Given /^I fill in the (\d+)[a-z]* supplied metadata value field with "([^"]*)"$/ do |i, value|
  #try to use end-with
  input_elems = all(:xpath, ".//input[starts-with(@id, 'dataset_supplied_metadata_attributes_')]")
  input_elems[i.to_i-1].set(value)
end

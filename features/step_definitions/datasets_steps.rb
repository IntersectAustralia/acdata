Given /^I have the usual datasets$/ do
  step "I have the usual samples"
  step "I have the usual instrument file types"
  step "I have the usual instruments"
  step "I have the following datasets", table(%{
      | name     | sample | instrument                     |
      | dataset1 | s1     | Autolab PGSTAT 12 Potentiostat |
      | dataset2 | s2     | Perkin Elmer Ramanstation 400  |
  })
end

Given /^I have the following datasets$/ do |table|
  table.hashes.each do |row|
    sample = Sample.find_by_name(row[:sample])
    instrument = Instrument.find_by_name(row[:instrument])
    raise "#{row[:instrument]} not found" unless instrument
    Factory(:dataset, :name => row[:name], :sample => sample, :instrument => instrument)
  end
end

Given /^I have the following files in a dataset$/ do |table|
  table.hashes.each do |row|
    dataset = Dataset.find_by_name(row[:dataset])
    attachment = Factory(:attachment,
                         :filename => row[:filename],
                         :dataset => dataset)
  end
end

When /^I have the usual instruments$/ do
  step "I have the default handle range"

  config_file = "#{Rails.root}/config/instruments.yml"
  config = YAML::load_file(config_file)
  instrument_set = ENV["RAILS_ENV"] || "development"
  config[instrument_set].each do |hash|
    next if hash['name'].nil? || hash['instrument_class'].nil?
    if hash.include?('instrument_file_types')
      file_types = hash['instrument_file_types'].map { |name| InstrumentFileType.find_by_name(name) }
      hash['instrument_file_types'] = file_types
    end
    if hash.include?('instrument_rules')
      rules = InstrumentRule.create(hash['instrument_rules'])
      hash['instrument_rule'] = rules
      hash.delete('instrument_rules')
    end
    i = Instrument.new(hash)
    i.save!
    AndsHandle.assign_handle(i)
  end
end

When /^I have the usual instrument file types$/ do
  config_file = "#{Rails.root}/config/instrument_file_types.yml"
  config = YAML::load_file(config_file)
  file_set = ENV["RAILS_ENV"] || "development"
  config[file_set]['instrument_file_types'].each do |hash|
    InstrumentFileType.create!(hash)
  end
end

When /^I have a dataset "([^"]*)" for sample "([^"]*)"$/ do |name, sample|
  Factory(:dataset, :name => name, :sample => Sample.find_by_name(sample))
end

When /^I have uploaded "([^"]*)" through the applet for dataset "([^"]*)" as user "([^"]*)"$/ do |file_tag, dataset_name, userid|
  applet_upload(file_tag, dataset_name, userid)
end

When /^I upload "([^"]*)" through the applet for dataset "([^"]*)" as user "([^"]*)"$/ do |file_tag, dataset_name, userid|
  filename = applet_upload(file_tag, dataset_name, userid)
  page.driver.browser.execute_script %Q{ uploadStarting( "#{filename}"); }
  json = "{\"#{filename}\":{\"status\":\"success\",\"message\":\"\"}}"
  page.driver.browser.execute_script %Q{ uploadFinished('#{json}'); }
end

Then /^I should see metadata fields$/ do |table|
  table.rows.each do |row|
    page.should have_content("#{row[0]}: #{row[1]}")
  end
end

Then /^I should get a download of dataset "([^"]*)"$/ do |dataset|
  current_path = URI.parse(current_url).path
  current_path.should == path_to("the download page for dataset \"#{dataset}\"")
end

Then /^I should see the jspecview applet$/ do
  page.should have_content('jspecview')
end

Given /^I close the dataset wizard$/ do
  page.find(:css, selector_for("close dataset wizard")).click
end

When /^I wait for the applet to load$/ do
  with_scope("next button") {
    begin
      sleep 1
    end until page.first(:xpath, "input[@disabled]").nil?
  }
end

When /^the applet has loaded$/ do
  page.driver.browser.execute_script %Q{ appletReady(); }
end

Then /^I should see the list of files for "([^"]*)"$/ do |dataset_name|
  dataset = Dataset.find_by_name(dataset_name)
  dataset.attachments.each do |att|
    page.should have_content(att.filename)
  end
end

Then /^I should (?:have|see) a warning containing "([^"]+?)"$/ do |text|
  page.driver.browser.switch_to.alert.text.should have_content(text)
end

And /^I have exported dataset "([^"]*)" to ELN$/ do |name|

  dataset = Dataset.find_by_name(name)
  Factory(:eln_export, :dataset_id => dataset.id)
end

Then /^I should have a dataset "([^"]*)" under sample "([^"]*)"$/ do |dataset_name, sample_name|
  dataset = Dataset.find_by_name(dataset_name)
  sample = Sample.find_by_name(sample_name)
  dataset.sample.should == sample
end

Then /^the attachments for "([^"]*)" should be moved from "([^"]*)" to "([^"]*)"$/ do |dataset_name, from_sample_name, to_sample_name|
  dataset = Dataset.find_by_name(dataset_name)
  from_sample = Sample.find_by_name(from_sample_name)
  to_sample = Sample.find_by_name(to_sample_name)
  dataset.sample.should == to_sample
  dataset.attachments.each do |att|
    expected_path = File.join(dataset.dataset_path, att.filename)
    att.path.should == expected_path
    old_path = File.join(from_sample.sample_path, "dataset_#{dataset.id}", att.filename)
    File.exists?(old_path).should be_false
    File.exists?(expected_path).should be_true
    if PreviewBuilder.is_image?(att.filename)
      expected_prev_path = PreviewBuilder.filepath(File.join(dataset.dataset_path, att.filename), APP_CONFIG['preview_format'])
      att.preview_file_path.should == expected_prev_path
    end
  end
end

Then /^I should have a preview file for "([^"]*)"$/ do |filename|
  att = Attachment.find_by_filename(filename)
  att.preview_file.should_not be_nil
  File.exists?(att.preview_file_path).should be_true
end

Then /^I should see the preview image for "([^"]*)"$/ do |filename|
  att = Attachment.find_by_filename(filename)
  path = preview_attachment_path(att)
  with_scope('Show Files') do
    page.should have_xpath("//img[contains(@src, '#{path}')]")
  end
end


Then /^I should have a visualisation for "([^"]*)"$/ do |dataset_name|
  dataset = Dataset.find_by_name(dataset_name)
  dataset.visual_attachment_path.should_not be_nil
end


def applet_upload(file_tag, dataset_name, userid)
  user = User.find_by_login(userid)
  #post to the upload controller just like the applet would
  # /attachments/upload?auth_token=WJkERciAORJDwGzBjx9O
  dataset = Dataset.find_by_name(dataset_name)
  sample_id = dataset.sample.id
  user.reset_authentication_token!
  token = user.authentication_token
  post_path = upload_attachments_path(:auth_token => token)
  file_name = case file_tag
                when "sample sp file 1"
                  "Ramanstation Spectrum File 1_SP.SP"
                when "sample JCAMP-DX file 1"
                  "ramanstation.dx"
                when "sample potentiostat frp file 1"
                  "potentiostat.frp"
                when "sample potentiostat ifi file 1"
                  "potentiostat.ifi"
                when "sample potentiostat ifw file 1"
                  "potentiostat.ifw"
                when "sample potentiostat ofw file 1"
                  "potentiostat.ofw"
                when "sample potentiostat txt file 1"
                  "potentiostat.txt"
                else
                  file_tag
              end
  file_path = "#{Rails.root}/features/samples/#{file_name}"
  raise "Can't find test file: #{file_name}" unless File.exists?(file_path)
  file = Rack::Test::UploadedFile.new(file_path, "application/octet-stream")
  post post_path, {"file_9004" => file, "dirStruct" => "[{\"file_9004\":\"#{file_name}\"}]", "destDir"=>"#{sample_id}/#{dataset.id}"}
  return file_name

end

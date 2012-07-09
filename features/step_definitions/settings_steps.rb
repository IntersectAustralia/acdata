When /^I have the default handle range$/ do
  Settings.instance.update_attribute(:start_handle_range, "hdl:1959.4/004_300")
  Settings.instance.update_attribute(:end_handle_range, "hdl:1959.4/004_2000")
end

When /^I set the start handle range to "([^"]*)"$/ do |text|
  Settings.instance.update_attribute(:start_handle_range, text)
end

When /^I set the end handle range to "([^"]*)"$/ do |text|
  Settings.instance.update_attribute(:end_handle_range, text)
end

When /^I have the usual slide scanning email$/ do
  Settings.instance.update_attribute(:slide_scanning_email, "acdata@unsw.edu.au")
end